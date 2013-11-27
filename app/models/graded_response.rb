# == Schema Information
#
# Table name: graded_responses
#
#  id             :integer         not null, primary key
#  student_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  examiner_id    :integer
#  disputed       :boolean         default(FALSE)
#  q_selection_id :integer
#  system_marks   :float
#  testpaper_id   :integer
#  scan           :string(40)
#  subpart_id     :integer
#  page           :integer
#  marks_teacher  :float
#  closed         :boolean         default(FALSE)
#  feedback       :integer         default(0)
#

# Scan ID to send via Savon : scanId = quizId-testpaperId-studentId-page#

class GradedResponse < ActiveRecord::Base
  belongs_to :student
  belongs_to :examiner
  belongs_to :q_selection
  belongs_to :testpaper
  belongs_to :subpart
  has_many :tex_comments

  validates :q_selection_id, presence: true
  validates :student_id, presence: true

  def self.on_page(page)
    select{ |m| m.page? == page }
  end

  def self.in_quiz(id)
    # All responses to questions in a quiz
    where(q_selection_id: QSelection.where(quiz_id: id).map(&:id))
  end

  def self.in_testpaper(id)
    where(testpaper_id: id)
  end

  def self.of_student(id)
    where(student_id: id)
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

  def self.disputed
    # Open disputes
    graded.where(disputed: true, closed: false)
  end

  def self.disputable
    # If a graded response has not been disputed X days after it got graded, then it 
    # should be deemed to have been accepted and should no longer be disputable
    graded.where(disputed: false, closed: false)
  end

  def self.closed
    where(closed: true)
  end

  def self.annotations( clicks )
    # This method creates the array of hashes web-service expects from 
    # what canvas.decompile() returns - via params[:clicks]
    # 'clicks' is of the form _R_ .... _G_ .... _T_ ...._C_, where R=red, T=turmeric, G=green

    ret = [] # passed to web-service request 
    # x_correction = 15 # see canvas.drawImage() call in canvas.js

    ['cross', 'check', 'ques', 'comment'].each_with_index do |m,j|
      pts = clicks.split("_#{m}b_").last.split("#{m}e_").first
      next if pts.blank?

      unless m == 'comment'
        pts = pts.split('_').select{ |m| !m.blank? }.map(&:to_i)
        pts.each_slice(2) do |pt|
          ret.push({ :x => pt.first, :y => pt.last, :code => j })
        end
      else
        comments = pts.split "@dwr@" # Comes from canvas.js. See note there
        comments.each_slice(3) do |comment|
          ret.push({ :x => comment[0].to_i, :y => comment[1].to_i, :code => 3, :text => comment[2]})
        end
      end
    end

    return ret
  end # of method

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
    frac = (self.system_marks / self.subpart.marks).round(2)
    return :light if frac < 0.3
    return :medium if frac < 0.85
    return :dark if frac < 0.95
    return :green
  end

  def marks?
    return (self.marks_teacher.nil? ? self.system_marks : self.marks_teacher)
  end

  def fdb( ids ) 
    # ids = list of Requirement indices extracted from params[:checked] 
    m = Requirement.mangle_into_feedback ids
    n = Requirement.marks_if? ids
    marks = self.subpart.marks
    earned = (n * marks).round(2)

    self.reset if self.feedback # over-write previous feedback 

    if self.update_attributes(feedback: m, system_marks: earned)
      # Increment n_graded count of the grading examiner
      e = Examiner.find self.examiner_id
      n_graded = e.n_graded + 1
      e.update_attribute :n_graded, n_graded

      # Time to send mails 
      tp = Testpaper.where(id: self.testpaper_id).first
      ws = AnswerSheet.where(student_id: self.student_id).where(testpaper_id: self.testpaper_id).first

      if tp.publishable? # to the teacher - once all worksheets are graded
        # Time to inform the teacher. You can do this only if teacher has provided 
        # an e-mail address. The default we assign will not work
        teacher = tp.quiz.teacher 
        Mailbot.grading_done(tp).deliver if teacher.account.email_is_real?
      end 

      if ws.publishable? # to the student if his/her worksheet has been graded
        Mailbot.worksheet_graded(ws).deliver if self.student.account.email_is_real? 
      end

    end # of if 
  end

  def reset(soft = true)
    # For times when a graded response has to be re-graded. Set the grade_id 
    # for the response to nil - as also the marks, graded? and honest? fields of the 
    # corresponding answer sheet 

    self.update_attribute :feedback, 0
    a = AnswerSheet.where(testpaper_id: self.testpaper_id, student_id: self.student_id).first
    a.update_attributes( marks: nil, graded: false, honest: nil) unless a.nil? 

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

    if self.scan
      page = self.scan[10].to_i(36)
      # quiz, testpaper, student, page = self.scan.split('-').map(&:to_i)
    else
      start_pg = QSelection.where(id: self.q_selection_id).select(:start_page).first.start_page
      offset = Subpart.where(id: self.subpart_id).select(:relative_page).first.relative_page
      page = start_pg + offset
    end
    self.update_attribute :page, page unless page < 1
    return page
  end

  def siblings_same_worksheet
    # same student, same worksheet
    ids = GradedResponse.in_testpaper(self.testpaper_id).of_student(self.student_id).map(&:id) - [self.id]
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
    return self.subpart.name_if_in? self.testpaper.quiz_id
  end

  def teacher?
    # Returns the teacher to whose quiz this graded response is
    return Teacher.where(id: self.testpaper.quiz.teacher_id).first
  end

  def scan_id
    # QR Code for the page on which this Graded Response appears
      ws_id = self.testpaper_id
      student_idx = AnswerSheet.where(testpaper_id: ws_id).map(&:student_id).sort.index(self.student_id)
      return encrypt(ws_id, 7) + encrypt(student_idx, 3) + self.page?.to_s(36)
  end

  def version
    # Returns the version the student got and for which this is the graded response
    signature = AnswerSheet.where(student_id: self.student_id, testpaper_id: self.testpaper_id).map(&:signature).first
    return "0" if signature.blank?

    j = self.q_selection.index
    return signature[j]
  end

end
