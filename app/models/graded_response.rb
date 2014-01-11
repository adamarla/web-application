# == Schema Information
#
# Table name: graded_responses
#
#  id             :integer         not null, primary key
#  student_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  examiner_id    :integer
#  q_selection_id :integer
#  marks          :float
#  scan           :string(40)
#  subpart_id     :integer
#  page           :integer
#  feedback       :integer         default(0)
#  worksheet_id   :integer
#

# Scan ID to send via Savon : scanId = quizId-examId-studentId-page#

class GradedResponse < ActiveRecord::Base
  belongs_to :student
  belongs_to :examiner
  belongs_to :q_selection
  belongs_to :worksheet
  belongs_to :subpart
  has_many :tex_comments, dependent: :destroy

  validates :q_selection_id, presence: true
  validates :student_id, presence: true

  after_create :page? # fix it now so that if Quiz layout changes tomorrow, then things still work

  def self.on_page(page)
    select{ |m| m.page? == page }
  end

  def self.in_quiz(id)
    # All responses to questions in a quiz
    where(q_selection_id: QSelection.where(quiz_id: id).map(&:id))
  end

  def self.in_exam(id)
    where(worksheet_id: Exam.find(id).worksheet_ids)
  end

  def self.of_student(id)
    where(student_id: id)
  end

  def self.in_worksheet(id)
    where(worksheet_id: id)
  end

  def self.to_db_question(id)
    where(q_selection_id: QSelection.where(question_id: id).map(&:id))
  end

  def self.to_question(index)
    where(q_selection_id: QSelection.where(index: index).map(&:id))
  end

  def self.assigned_to(id)
    where(examiner_id: id)
  end

  def self.unassigned
    where(examiner_id: nil)
  end
  
  def self.graded
    where("feedback > ?", 0)
  end 

  def self.ungraded
    where(feedback: 0)
  end

  def self.with_scan
    where('scan IS NOT NULL')
  end

  def self.without_scan
    where('scan IS NULL')
  end

  def self.on_topic(topic_id)
    select{ |m| m.q_selection.question.topic.id == topic_id }
  end

  def self.to_subpart(subpart)
    select{ |m| m.subpart.index == subpart }
  end

  def self.standalone
    # Relatively time expensive. Chain towards the end 
    select{ |m| m.q_selection.question.num_parts? == 0 }
  end

  def self.received_on(date) # Ex: date = '16th Dec 2013'
    where('scan LIKE ?', "#{Date.parse(date).strftime('%d.%B.%Y')}%")
  end

  def shadow?
    quiz = self.worksheet.exam.quiz
    return 0 if quiz.nil?
    
    shadows = quiz.shadows.split(',').map(&:to_i) # as an array of integers
    idx = quiz.subparts.index self.subpart
    return shadows[idx]
  end

  def marks?
    return self.marks
  end

  def fdb( ids ) 
    # ids = list of Requirement indices extracted from params[:checked] 
    m = Requirement.mangle_into_feedback ids
    n = Requirement.marks_if? ids
    marks = self.subpart.marks
    earned = (n * marks).round(2)

    self.reset if self.feedback # over-write previous feedback 

    if self.update_attributes(feedback: m, marks: earned)
      # Increment n_graded count of the grading examiner
      e = Examiner.find self.examiner_id
      n_graded = e.n_graded + 1
      e.update_attribute :n_graded, n_graded

      # Time to send mails 
      exam = Exam.where(id: self.worksheet.exam_id).first
      ws = Worksheet.where(student_id: self.student_id).where(exam_id: self.worksheet.exam_id).first

      if exam.publishable? # to the teacher - once all worksheets are graded
        # Time to inform the teacher. You can do this only if teacher has provided 
        # an e-mail address. The default we assign will not work
        teacher = exam.quiz.teacher 
        Mailbot.delay.grading_done(exam) if teacher.account.email_is_real?
      end 

      if ws.publishable? # to the student if his/her worksheet has been graded
        Mailbot.delay.worksheet_graded(ws) if self.student.account.email_is_real? 
      end

    end # of if 
  end

  def reset(soft = true)
    # For times when a graded response has to be re-graded. Set the grade_id 
    # for the response to nil - as also the marks, graded? and honest? fields of the 
    # corresponding answer sheet 

    self.update_attribute :feedback, 0
    w = self.worksheet
    w.update_attributes( marks: nil, graded: false, honest: nil) unless w.nil? 

    # Soft (default) reset -> does NOT destroy any associated TexComments
    # Hard reset -> also destroys any associated TeXComments
    self.tex_comments.map(&:destroy) unless soft
  end 

  def index?
    # The index of the question / subpart to which this is the graded response
    # Hence, if sth. like 2.4 is returned, then it means that this graded response 
    # is for the 4th subpart of the second question in the quiz
    return ( self.q_selection.index + ( self.subpart.index/10.0)).round(1)
  end

  def page?
    return self.page unless self.page.nil? 

    brks_wthn = self.q_selection.page_breaks? # returns an array of integers!! 
    rel_sbp_index = self.subpart.index 
    last_brk_at = brks_wthn.select{ |b| b < rel_sbp_index }.last 
    offset = last_brk_at.nil? ? 0 : brks_wthn.index(last_brk_at) + 1

    page = self.q_selection.start_page + offset
    self.update_attribute :page, page 
    return page
  end

  def siblings_same_worksheet
    # same student, same worksheet
    ids = GradedResponse.in_worksheet(self.worksheet_id).map(&:id) - [self.id]
    GradedResponse.where(id: ids)
  end

  def siblings_same_page
    # same student, same worksheet, same page 
    pg = self.page?
    self.siblings_same_worksheet.on_page(pg)
  end

  def siblings_same_question
    # same student, same worksheet, same question - perhaps different pages
    db_question_id = self.subpart.question_id 
    ids = self.siblings_same_worksheet.to_db_question(db_question_id).map(&:id) - [self.id]
    GradedResponse.where(id: ids)
  end

  def name?
    # The name of a graded response is a function of the quiz it is in, the
    # index of the parent question in the quiz and the index of the corresponding sub-part 
    # relative to the parent question 
    return self.subpart.name_if_in? self.worksheet.exam.quiz_id
  end

  def teacher?
    # Returns the teacher to whose quiz this graded response is
    return Teacher.where(id: self.worksheet.exam.quiz.teacher_id).first
  end

  def version
    # Returns the version the student got and for which this is the graded response
    signature = self.worksheet.map(&:signature).first
    signature = Worksheet.where(student_id: self.student_id, exam_id: self.worksheet.exam_id).map(&:signature).first
    return "0" if signature.blank?

    j = self.q_selection.index - 1 # QSelection.index is 1-indexed - not 0-indexed
    return signature[j]
  end

  def honest?
    return :disabled if self.scan.nil?
    return :nodata unless self.feedback
    
    posn = self.feedback & 15 
    score = Requirement.honest.where(posn: posn).map(&:weight).first

    case score
      when 0 then return :red
      when 1,2,3 then return :orange
      else return :green
    end
  end 

  def colour? 
    return :disabled if (self.scan.nil? or self.feedback == 0)

    honest = Requirement.honest.where(posn: (self.feedback & 15)).map(&:weight).first
    return :red if honest == 0
    frac = (self.marks / self.subpart.marks).round(2)
    return :light if frac < 0.3
    return :medium if frac < 0.85
    return :dark if frac < 0.95
    return :green
  end

end # of class
