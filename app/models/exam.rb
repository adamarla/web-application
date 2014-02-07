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
#  open        :boolean         default(TRUE)
#

include GeneralQueries

class Exam < ActiveRecord::Base
  belongs_to :quiz

  has_many :graded_responses, dependent: :destroy
  has_many :worksheets, dependent: :destroy
  has_many :students, through: :worksheets

  after_create :seal

  def self.takehome
    where(takehome: true)
  end

  def self.timed
    where{ duration != nil }
  end

  def self.with_deadline
    where{ deadline != nil }
  end

  def self.for_quiz(id)
    where(quiz_id: id)
  end 

  def self.open
    where(open: true)
  end 

  def close? 
    # Should the exam be closed to further students at the time of asking?
    if self.quiz.teacher.online
      today = Date.today
      created = self.created_at
      return (today.month != created.month && today.year != created.year) 
    else
      return false # must be closed explicitly AFTER all students have been added
    end
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

  def path? 
    return "#{self.quiz.uid}/#{self.uid}"
  end 

  def deadline? 
    # Returns the ** number of days ** left to finish grading this exam
    # Numbers < 0 => deadline missed 

    if self.deadline.nil?
      g = GradedResponse.in_exam(self.id).with_scan.ungraded.order(:updated_at).last
      d = g.nil? ? 3.business_days.from_now : (3.business_days.after g.updated_at)
      self.update_attribute(:deadline, d) 
    end

    deadln = self.deadline.nil? ? 0 : (self.deadline.to_date - Date.today).to_i
    return deadln
  end

  def percent_graded?
    g = GradedResponse.in_exam(self.id).with_scan
    return 0 if g.count == 0
    ret = (( g.graded.count.to_f / g.count )*100).round
    return ret
  end

  def write 
    response = {} 
    return response if self.takehome 

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['write_tex']}" 
    response = SavonClient.request :wsdl, :writeTex do
      soap.body = { 
        target: self.path?,
        mode: 'exam',
        imports: Worksheet.where(exam_id: self.id).map(&:path?) 
      }
      end
  end 

  def compile 
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['compile_tex']}" 
    response = SavonClient.request :wsdl, :compileTex do
      soap.body = { path: self.path? }
    end
    return response
  end

  def error_out
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['error_out']}" 
    response = SavonClient.request :wsdl, :errorOut do
      soap.body = { path: self.path? }
    end
    return response[:error_out_response][:manifest]
  end

  def download_pdf?
    return nil unless self.compiled?
    return nil if self.takehome
    return "#{Gutenberg['server']}/mint/#{self.path?}/document.pdf"
  end

  public 
    def seal 
      uid = self.uid.nil? ? "e/#{rand(999)}/#{self.id.to_s(36)}" : self.uid
      self.update_attribute :uid, uid

      # Only for exams made by online instructors can we do the following
      # For those in schools, Quiz.mass_assign_to will set the 'name' 
      # and 'takehome' flags
      if self.quiz.teacher.online
        created = self.created_at
        name = "#{created.strftime("%B %Y")}"
        self.update_attributes name: name, takehome: true
      end
    end

end # of class
