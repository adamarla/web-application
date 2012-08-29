# == Schema Information
#
# Table name: testpapers
#
#  id          :integer         not null, primary key
#  quiz_id     :integer
#  name        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  publishable :boolean         default(FALSE)
#  exclusive   :boolean         default(TRUE)
#

class Testpaper < ActiveRecord::Base
  belongs_to :quiz

  has_many :graded_responses, :dependent => :destroy 
  has_many :answer_sheets, :dependent => :destroy
  has_many :students, :through => :answer_sheets

  def compile_tex
    student_ids = AnswerSheet.where(:testpaper_id => self.id).select(:student_id).map(&:student_id)
    students = Student.where(:id => student_ids)

    names = []
    students.each do |s|
      names.push({ :id => s.id, :name => s.name })
    end

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['assign_quiz']}"

    response = SavonClient.request :wsdl, :assign_quiz do  
      soap.body = { 
        :quiz => { :id => self.quiz_id, :name => self.quiz.teacher.school.name },
        :instance => { :id => self.id, :name => self.name },
        :students => names 
      }
    end
    return response.to_hash[:assign_quiz_response]
  end #of method

  def mean?
    # Returns the average % for the class/group that took this testpaper
    # Only graded responses and only those students that have
    # some or all of their answer-sheet graded are considered. Hence, know 
    # that this number will change with time before settling to a final value

    individual_scores = []
    AnswerSheet.where(:testpaper_id => self.id).each do |a|
      thus_far = a.graded_thus_far?
      next if thus_far == 0
      marks = a.marks? 
      score = ((marks/thus_far)*100).round(2)
      individual_scores.push score
    end

    unless individual_scores.empty?
      total = individual_scores.inject(:+)
      mean = (total / individual_scores.count).round(2)
    else
      mean = 0
    end
    return mean
  end

  def retotal
    # This is for those times when a teacher changes her grade allotments and wants
    # a past testpaper to reflect the new allotments. This is not something we encourage. 
    # But better to have the option than not. At any rate, the grade is not changed

    self.answer_sheets.each do |m|
      m.update_attribute :marks, nil # will be re-calculated on next call to marks?
    end

    self.graded_responses.graded.each do |m|
      grade = m.grade
      marks = (m.subpart.marks * (grade.allotment/100.0)).round(2)
      m.update_attribute :marks, marks
    end
  end

  def takers
    self.students.order(:first_name)
  end

  def self.name_if_students?(student_ids)
    sektion_ids = StudentRoster.where(:student_id => student_ids).map(&:sektion_id).uniq
    sektions = Sektion.where(:id => sektion_ids).order(:klass).order(:name)
    klasses = sektions.map(&:klass).uniq

    name = ""
    klasses.each do |k|
      name.concat " #{k} - #{sektions.where(:klass => k).map(&:name).join(", ")} "  
    end
    return name.strip # example: 11-(A,B,Weak students) 12-(A)
  end

  def rebuild_testpaper_report_pdf
    answer_sheets = AnswerSheet.where(:testpaper_id => self.id).map{ |m|
      unless m.marks.nil?
        marks = "#{m.marks}/#{self.quiz.total}"
      else
        marks = "n/a"
      end
      { :id => m.student_id, :name => m.student.name, 
        :value => "#{marks}"}
    }
    answer_sheets.push({ :id => "", :name => "", :value => ""}) if answer_sheets.count.odd?

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['generate_quiz_report']}"
    school = self.quiz.teacher.school
    response = SavonClient.request :wsdl, :generate_quiz_report do
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

end # of class
