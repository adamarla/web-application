# == Schema Information
#
# Table name: exams
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
#  uid         :string(40)
#

include GeneralQueries

class Exam < ActiveRecord::Base
  belongs_to :quiz

  has_many :graded_responses, dependent: :destroy
  has_many :worksheets, dependent: :destroy
  has_many :students, through: :worksheets

  def self.takehome
    where(takehome: true)
  end

  def self.timed
    where{ duration != nil }
  end

  def self.with_deadline
    where{ deadline != nil }
  end

  def gradeable?
    return false unless self.has_scans?
    GradedResponse.in_exam(self.id).with_scan.ungraded.count > 0
  end

  def has_scans?
    # if false, then worksheet / exam is automatically ungradeable
    ret = GradedResponse.in_exam(self.id).with_scan.count > 0
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
    worksheets = Worksheet.where(exam_id: self.id)
    students = Student.where(id: worksheets.map(&:student_id)).order(:id) 

    names = []
    students.each_with_index do |s,j|
      signature = worksheets.where(student_id: s.id).map(&:signature?).first
      names.push({ id: s.id, name: s.name, value: encrypt(j,3), signature: signature })
    end

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['assign_quiz']}"

    response = SavonClient.request :wsdl, :assignQuiz do  
      soap.body = { 
        quiz: { id: self.quiz_id, name: self.quiz.latex_safe_name, value: encrypt(self.quiz_id, 7) },
        instance: { id: self.id, name: self.name, value: encrypt(self.id, 7) },
        students: names,
        publish: self.takehome
      }
    end
    response = response.to_hash[:assign_quiz_response]
    if !response[:manifest].blank?
      if self.takehome
        students.each_with_index do |s,j|
          Delayed::Job.enqueue ProcessWorksheet.new(self, s, j), priority: 5
        end
      end
    end
    return response
  end #of method

  def process_worksheet(student, index)

    names = [{ id: student.id, name: student.name, value: encrypt(index,3) }]

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['prep_test']}"
    response = SavonClient.request :wsdl, :prepTest do  
      soap.body = { 
        quiz: { id: self.quiz_id, name: self.quiz.latex_safe_name , value: encrypt(self.quiz_id, 7) },
        instance: { id: self.id, name: self.name , value: encrypt(self.id, 7) },
        students: names 
      }
    end
    if self.takehome
      email = student.account.real_email
      Mailbot.delay.quiz_assigned(self, student) unless email.nil?
    end
    return response.to_hash[:prep_test_response]
  end #of method

  def to_csv(options = {})
    csv = []
    CSV.generate(options) do |csv|
      csv << ["Name", "Marks(#{self.quiz.total?} max)"]
      self.students.order(:first_name).each do |s|
        as = Worksheet.for_exam(self.id).of_student(s.id).first
        if as.graded?
          csv << [s.name, as.marks]
        end
      end
    end
  end

  #Only for legacy Exams, not needed going forward from Oct1, 2013
  def compile_solution_tex
    student_ids = Worksheet.where(exam_id: self.id).select(:student_id).map(&:student_id)
    students = Student.where(id: student_ids).order(:id)

    names = []
    students.each_with_index do |s,j|
      names.push({ id: s.id, name: s.name, value: encrypt(j,3) })
    end

    students.each_with_index do |s,j|
      Delayed::Job.enqueue ProcessWorksheet.new(self, s, j), priority: 6
    end
  end

  def mean?
    # Returns the average for the class/group that took this exam
    # Only graded responses and only those students that have
    # some or all of their answer-sheet graded are considered. Hence, know 
    # that this number will change with time before settling to a final value
    
    g = GradedResponse.in_exam(self.id).graded
    return 0 if g.blank?
    total = g.map(&:marks).inject(:+)
    nsubm = g.map(&:student_id).uniq.count
    return (total / nsubm).round(2)
  end

  def takers
    self.students.order(:first_name)
  end

  def submitters
    # Returns list of students who have made some submission for this exam.
    # Can change as more scans come in
    ids = GradedResponse.in_exam(self.id).with_scan.map(&:student_id).uniq
    Student.where(id: ids)
  end

  def closed_on?
    # Returns the approximate date when grading for this exam / worksheet was finished
    last = Worksheet.where(exam_id: self.id).order(:updated_at).last.updated_at
  end

  def rebuild_exam_report_pdf
    worksheets = Worksheet.where(exam_id: self.id).map{ |m|
      { id: m.student_id, name: m.student.name, value: "#{m.marks?}/#{self.quiz.total?}" }
    }
    worksheets.push({ id: "", name: "", value: "" }) if worksheets.count.odd?

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['generate_quiz_report']}"
    school = self.quiz.teacher.school
    response = SavonClient.request :wsdl, :generateQuizReport do
      soap.body = {
        school: { id: school.id, name: school.name }, 
        group: { id: self.id, name: self.pdf },
        members: worksheets
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
