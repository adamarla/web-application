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
#  grade_by    :datetime
#  uid         :string(40)
#  open        :boolean         default(TRUE)
#  submit_by   :datetime
#  regrade_by  :datetime
#  dist_scheme :text
#  rubric_id   :integer
#

include GeneralQueries

class Exam < ActiveRecord::Base
  belongs_to :quiz

  has_many :tryouts, through: :worksheets
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
    where{ grade_by != nil }
  end

  def self.for_quiz(id)
    where(quiz_id: id)
  end 

  def self.open
    where(open: true)
  end 

  def rubric_id? 
    return self.rubric_id unless self.rubric_id.nil?
    t = self.quiz.teacher 
    rubric = t.rubric_id?
    self.update_attribute :rubric_id, rubric 
    return rubric 
  end 

  def close? 
    # Should the exam be closed to further students at the time of asking?
    if self.quiz.teacher.indie
      today = Date.today
      created = self.created_at
      return (today.month != created.month && today.year != created.year) 
    else
      return false # must be closed explicitly AFTER all students have been added
    end
  end 

  def gradeable?
    return false unless self.has_scans?
    Tryout.in_exam(self.id).with_scan.ungraded.count > 0
  end

  def disputable?
    # can a student dispute a grade at this time? 
    return true if self.regrade_by.nil?
    return (Date.today <= self.regrade_by.to_date)
  end

  def receptive?
    # of any new scans. If not, then further submissions are disallowed
    return true if self.submit_by.nil?
    return (Date.today <= self.submit_by.to_date) 
  end 

  def has_scans?
    # if false, then worksheet / exam is automatically ungradeable
    ret = Tryout.in_exam(self.id).with_scan.count > 0
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
    # Only tryouts and only those students that have
    # some or all of their answer-sheet graded are considered. Hence, know 
    # that this number will change with time before settling to a final value
    
    g = Tryout.in_exam(self.id).graded
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
    ids = Tryout.in_exam(self.id).with_scan.map(&:student_id).uniq
    Student.where(id: ids)
  end

  def sektion 
    tid = self.quiz.teacher_id 
    name = self.name.split('_').first 
    similarly_named = Sektion.where(teacher_id: tid, name: name)
    likely = similarly_named.where('created_at <= ?', self.created_at).order(:created_at)
    return likely.last
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
    return self.uid.blank? ? "#{self.quiz.uid}/sample" : "#{self.quiz.uid}/#{self.uid}"
  end 

  def grade_by? 
    # Returns the ** number of days ** left to finish grading this exam
    # Numbers < 0 => deadline missed 

    if self.grade_by.nil?
      g = Tryout.in_exam(self.id).with_scan.ungraded.order(:updated_at).last
      d = g.nil? ? 3.business_days.from_now : (3.business_days.after g.updated_at)
      self.update_attribute(:grade_by, d) 
    end

    deadln = self.grade_by.nil? ? 0 : (self.grade_by.to_date - Date.today).to_i
    return deadln
  end

  def percent_graded?
    g = Tryout.in_exam(self.id).with_scan
    return 0 if g.count == 0
    ret = (( g.graded.count.to_f / g.count )*100).round
    return ret
  end

  def write
    response = {} 
    
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

  def distribution_scheme?
    return {} if self.dist_scheme.blank?
    return YAML.load self.dist_scheme
  end

  def reset
    # Resets examiner_id so that work can be distributed as per new distribution scheme 
    g = Tryout.in_exam(self.id).with_scan.ungraded
    g.each do |j|
      j.update_attribute :examiner_id, nil
    end
  end

  def perception?(sid)
    # Returns one of [:red | :orange | :green | :blank | :disabled ] 
    # representing the overall sense of what the student has done in the exam
    w = Worksheet.where(student_id: sid, exam_id: self.id).first
    return w.nil? ? :disabled : (w.received?(:none) ? :disabled : w.perception?)
  end 

  def spectrum?(sid)
    # Returns perceptions - as color codes - for every response 
    # by a student in the given exam
    w = Worksheet.where(exam_id: self.id, student_id: sid).first 
    w.nil? ? [] : w.spectrum?
  end 

  def deleteFiles()
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['destroy_exam']}"
    response = SavonClient.request :wsdl, :destroyExam do
      soap.body = {
        :uid => self.quiz.uid,
        :worksheet_uid => self.worksheets.map(&:uid)
      }
    end
    manifest = response[:destroy_exam_response][:manifest]
    return manifest.nil?
  end

  private 
    def seal 
      t = quiz.teacher 
      rubric = t.rubric_id?

      update_attribute(:rubric_id, rubric) unless rubric.nil?
      if t.indie 
        name = "#{created_at.strftime("%B %Y")}"
        update_attributes name: name, takehome: true
      end 
      # Setting the uid => exam needs to be written. Hence, defer the setting to write() 
    end

end # of class
