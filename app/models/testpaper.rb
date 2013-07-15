# == Schema Information
#
# Table name: testpapers
#
#  id          :integer         not null, primary key
#  quiz_id     :integer
#  name        :string(100)
#  created_at  :datetime
#  updated_at  :datetime
#  publishable :boolean         default(FALSE)
#  takehome    :boolean         default(FALSE)
#  job_id      :integer         default(-1)
#  duration    :integer
#  deadline    :datetime
#

include GeneralQueries

class Testpaper < ActiveRecord::Base
  belongs_to :quiz

  has_many :graded_responses, :dependent => :destroy 
  has_many :answer_sheets, :dependent => :destroy
  has_many :students, :through => :answer_sheets

  def self.takehome
    where(:takehome => true)
  end

  def self.timed
    where{ duration != nil }
  end

  def self.with_deadline
    where{ deadline != nil }
  end

  def gradeable?
    return false unless self.has_scans?
    GradedResponse.in_testpaper(self.id).with_scan.ungraded.count > 0
  end

  def has_scans?
    # if false, then worksheet / testpaper is automatically ungradeable
    ret = GradedResponse.in_testpaper(self.id).with_scan.count > 0
    return ret
  end

  def publishable? 
    return true if self.publishable

    ret = (self.has_scans? & !self.gradeable?)
    self.update_attribute(:publishable, true) if ret
    return ret
  end

  def compiling?
    # job_id = -1 => default initial state
    #        > 0 => queued => compiling
    #        = 0 => compilation completed
    return self.job_id > 0
  end

  def compile_tex
    student_ids = AnswerSheet.where(:testpaper_id => self.id).select(:student_id).map(&:student_id)
    students = Student.where(:id => student_ids).order(:id)

    names = []
    students.each_with_index do |s,j|
      names.push({ :id => s.id, :name => s.name, :value => encrypt(j,3) })
    end

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['assign_quiz']}"

    response = SavonClient.request :wsdl, :assignQuiz do  
      soap.body = { 
        :quiz => { :id => self.quiz_id, :name => self.quiz.latex_safe_name, :value => encrypt(self.quiz_id, 7) },
        :instance => { :id => self.id, :name => self.name, :value => encrypt(self.id, 7) },
        :students => names 
      }
    end
    return response.to_hash[:assign_quiz_response]
  end #of method

  def compile_individual_tex(student_id)

    student_ids = AnswerSheet.where(:testpaper_id => self.id).select(:student_id).map(&:student_id)
    students = Student.where(:id => student_ids).order(:id)

    names = []
    students.each_with_index do |s,j|
      if s[:id] == student_id
        names.push({ :id => s.id, :name => s.name, :value => encrypt(j,3) })
        break
      end
    end

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['prep_test']}"
    response = SavonClient.request :wsdl, :prepTest do  
      soap.body = { 
        :quiz => { :id => self.quiz_id, :name => self.quiz.latex_safe_name , :value => encrypt(self.quiz_id, 7) },
        :instance => { :id => self.id, :name => self.name , :value => encrypt(self.id, 7) },
        :students => names 
      }
    end
    return response.to_hash[:prep_test_response]
  end #of method

  def mean?
    # Returns the average for the class/group that took this testpaper
    # Only graded responses and only those students that have
    # some or all of their answer-sheet graded are considered. Hence, know 
    # that this number will change with time before settling to a final value

    individual_scores = []
    AnswerSheet.where(:testpaper_id => self.id).each do |a|
      thus_far = a.graded_thus_far?
      next if thus_far == 0
      marks = a.marks? 
      individual_scores.push marks
    end

    unless individual_scores.empty?
      total = individual_scores.inject(:+)
      mean = (total / individual_scores.count).round(2)
    else
      mean = 0
    end
    return mean
  end

  def takers
    self.students.order(:first_name)
  end

  def closed_on?
    # Returns the approximate date when grading for this testpaper / worksheet was finished
    last = AnswerSheet.where(:testpaper_id => self.id).order(:updated_at).last.updated_at
  end

  def rebuild_testpaper_report_pdf
    answer_sheets = AnswerSheet.where(:testpaper_id => self.id).map{ |m|
      { :id => m.student_id, :name => m.student.name, :value => "#{m.marks?}/#{self.quiz.total?}" }
    }
    answer_sheets.push({ :id => "", :name => "", :value => ""}) if answer_sheets.count.odd?

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['generate_quiz_report']}"
    school = self.quiz.teacher.school
    response = SavonClient.request :wsdl, :generateQuizReport do
      soap.body = {
        :school => { :id => school.id, :name => school.name },
        :group => { :id => self.id, :name => self.pdf },
        :members => answer_sheets 
      }
    end # of response 
    return response.to_hash[:generate_quiz_report]
  end

  def pdf
    # UNIX has problem w/ some non-word characters in filenames
    # TeX has a problem w/ most of the rest ( unless escaped ). No one has a problem
    # with the hyphen. So, we do everything to only have it in the PDF file name
    ts_name = "#{self.name.split(/[\s\W]+/).join('-')}"
    qz_name = "#{self.quiz.name.split(/[\s\W]+/).join('-')}"
    return "#{qz_name}-#{ts_name}"
  end

  def legacy_record?
    date = self.created_at.nil? ? Date.today : self.created_at
    return true if date.year < 2013
    return true if (date.year == 2013) && (date.month < 4)
    return false
  end

end # of class
