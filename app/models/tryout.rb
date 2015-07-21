# == Schema Information
#
# Table name: tryouts
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
#  mobile         :boolean         default(TRUE)
#  disputed       :boolean         default(FALSE)
#  resolved       :boolean         default(FALSE)
#  orange_flag    :boolean
#  red_flag       :boolean
#  weak           :boolean
#  medium         :boolean
#  strong         :boolean
#  first_shot     :integer
#

# Scan ID to send via Savon : scanId = quizId-examId-studentId-page#

class Tryout < ActiveRecord::Base
  belongs_to :student
  belongs_to :examiner
  belongs_to :q_selection
  belongs_to :worksheet
  belongs_to :subpart
  has_many :remarks, dependent: :destroy
  has_many :doodles, dependent: :destroy

  validates :q_selection_id, presence: true
  validates :student_id, presence: true

  before_update :reset_marks_color_quality, if: :feedback_changed?
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

  def self.received_on(date = :today) # Ex: date = '16th Dec 2013'
    dt = date == :today ? Date.today : Date.parse(date)
    date_str = dt.strftime('%d.%B.%Y') 
    where('scan IS NOT ? AND scan LIKE ?', nil, "#{date_str}%")
  end

  def self.received_in_last(n, ending = nil) # search range = [ ending-n.days, ending ]
    end_date = ending.nil? ? Date.today : Date.parse(ending)
    mid_dates = [*0..n].map{ |j| end_date - j.days }
    a = mid_dates.map{ |j| j.strftime('%B.%d.%Y') } 
    b = [] 
    b += a.map{ |d| Tryout.received_on(d) } 
    return b.flatten
  end 

  def self.disputed 
    where(disputed: true)
  end 

  def self.resolved 
    where(disputed: true, resolved: true)
  end 

  def self.unresolved
    where(disputed: true, resolved: false)
  end 

  def bullseye? 
    # Returns true if student's pick during self-check was correct. 
    # Else false ( or nil if not self-checked )
    return nil if self.first_shot.nil?
    return (self.first_shot == self.version.to_i)
  end

  def self_checked?
    return !self.first_shot.nil?
  end 

  def shadow?
    return 0 if self.mobile
    quiz = self.worksheet.exam.quiz
    return 0 if quiz.nil?
    
    curtain = quiz.shadows
    shadows = curtain.blank? ? [] : curtain.split(',').map(&:to_i) # as an array of integers
    return 0 if shadows.empty?
    idx = quiz.subparts.index self.subpart
    return shadows[idx]
  end

  def marks?
    return self.marks
  end

  def annotate(comments) 
    TexComment.record(comments, self.examiner_id, self.id, nil)
  end 
  
  def grade(criterion_ids)
    self.reset if self.feedback # over-write previous feedback 

    rubric = Rubric.find self.worksheet.exam.rubric_id? 
    f = rubric.fdb_if? criterion_ids 

    if (self.update_attributes(feedback: f))
      unless self.disputed
        # Increment n_graded count of the grading examiner
        e = Examiner.find self.examiner_id
        n_graded = e.n_graded + 1
        e.update_attribute :n_graded, n_graded

        # Previously, when submissions for all students came together, 
        # it made sense to send a mail when the last tryout was graded. 
        # Now, because of mobile uploads, scans can come in anytime. 
        # Hence, its best to give a weekly and monthly synopsis only.
      else # previously graded, but disputed now 
        self.update_attribute(:resolved, true)
      end
    end # of if..else  
  end # of method  

  def reset(soft = true)
    # For times when a tryout has to be re-graded. 
    # Setting feedback = 0 will trigger the following before_update 
    # callbacks on the Tryout and then on the worksheet
    self.update_attribute :feedback, 0

    # Soft (default) reset -> does NOT destroy any associated Remarks
    # Hard reset -> also destroys any associated Remarks
    self.remarks.map(&:destroy) unless soft
  end 

  def index?
    # The index of the question / subpart to which this is the tryout
    # Hence, if sth. like 2.4 is returned, then it means that this tryout 
    # is for the 4th subpart of the second question in the quiz
    return ( self.q_selection.index + ( self.subpart.index/10.0)).round(1)
  end

  def page?
    return self.page unless self.page.nil? 

    quiz = self.worksheet.exam.quiz
    all_sbp = quiz.subparts
    posn = all_sbp.index(self.subpart)
    breaks_after = quiz.page_breaks_after.split(',').map(&:to_i) # an array of indices
    last_brk_at = breaks_after.select{ |b| b < posn }.last
    pg = last_brk_at.nil? ? 1 : breaks_after.index(last_brk_at) + 2 
    self.update_attribute :page, pg
    return pg
  end

  def siblings_same_worksheet
    # same student, same worksheet
    ids = Tryout.in_worksheet(self.worksheet_id).map(&:id) - [self.id]
    Tryout.where(id: ids)
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
    Tryout.where(id: ids)
  end

  def name?
    # The name of a tryout is a function of the quiz it is in, the
    # index of the parent question in the quiz and the index of the corresponding sub-part 
    # relative to the parent question 
    return self.subpart.name_if_in? self.worksheet.exam.quiz_id
  end

  def teacher?
    # Returns the teacher to whose quiz this tryout is
    return Teacher.where(id: self.worksheet.exam.quiz.teacher_id).first
  end

  def version
    # Returns the version the student got and for which this is the tryout
    sign = self.worksheet.signature 
    return "0" if sign.blank?
    idx = self.q_selection.index - 1 # QSelections are 1-indexed - not 0-indexed
    sign = sign.split(',') # by itself, sign is a string
    ret = sign[idx]
    return (ret.blank? ? "0" : ret)
  end

  def quality?
    return :red if self.red_flag
    for m in [:weak, :medium, :strong]
      return m if self[m]
    end 
    return :blank
  end 

  def perception? 
    return :disabled if self.scan.nil?
    return :blank if self.feedback == 0
    return :red if self.red_flag 
    return :orange if self.orange_flag 
    return :green
  end 

  def regradeable? 
    return false if (self.scan.nil? || self.feedback == 0)
    return false if self.resolved  
    return false unless self.worksheet.exam.disputable?
    return true
  end 

  private 
      def reset_marks_color_quality
        if feedback == 0
          assign_attributes red_flag: false, orange_flag: false, marks: 0,
                            weak: false, medium: false, strong: false
          worksheet.update_attribute :graded, false # calls before_update callback of Worksheet model
        else 
          rubric = Rubric.find(worksheet.exam.rubric_id?)
          cids = rubric.criterion_ids_given(feedback)
          p = rubric.penalty_if? cids  
          max = subpart.marks 
          marks = ((( 100 - p )/100.0) * max).round(2)
          # Quality booleans 
          w = p >= 65
          m = (p < 65 && p > 15)
          s = (p <= 15)
          # Color booleans 
          colors = Criterion.where(id: cids).map(&:perception?)
          red = colors.include? :red
          orange = red ? false : colors.include?(:orange)  # only one of red or orange should be set  
          assign_attributes red_flag: red, orange_flag: orange, marks: marks, 
                            weak: w, medium: m, strong: s
        end 
      end 

end # of class
