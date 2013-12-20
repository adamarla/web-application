# == Schema Information
#
# Table name: quizzes
#
#  id            :integer         not null, primary key
#  teacher_id    :integer
#  created_at    :datetime
#  updated_at    :datetime
#  num_questions :integer
#  name          :string(70)
#  subject_id    :integer
#  total         :integer
#  span          :integer
#  parent_id     :integer
#  job_id        :integer         default(-1)
#

#     __:has_many_____     ___:has_many___  
#    |                |   |               | 
#  Teacher --------> Quizzes ---------> Questions 
#    |                |   |               | 
#    |__:belongs_to___|   |___:has_many___| 
#    

# When to destroy a Quiz ? 
# ------------------------
# 
# Destroying a Quiz is a massively destructive operation. If the Quiz goes, 
# then all associated data - student grades on that quiz, entries in course-pack
# etc. etc. must go too 
#
# So, here is what I think should be done. Let the teacher indicate that she 
# does not want to use a Quiz anymore. We hide the Quiz then. And if she really
# does not use it for - say, 3 months - then we really do destroy the Quiz (using a cronjob)

include GeneralQueries

class Quiz < ActiveRecord::Base
  belongs_to :teacher 

  has_many :q_selections, dependent: :destroy
  has_many :questions, through: :q_selections
  has_many :testpapers, dependent: :destroy
  has_many :drafts, dependent: :destroy

  # Quiz -> Coursework -> Milestone
  has_many :coursework 
  has_many :milestones, through: :coursework

  # Validations
  validates :teacher_id, presence: true, numericality: true
  validates :name, presence: true
  
  #before_validation :set_name, :if => :new_record?
  after_destroy :shred_pdfs

  def total? 
    return self.total unless self.total.nil? 
    question_ids = QSelection.where(:quiz_id => self.id).map(&:question_id)
    marks = Question.where(:id => question_ids).map(&:marks?)
    total = marks.inject(:+)
    self.update_attribute :total, total
    return total
  end

  def subparts
    # Returns the ordered list of subparts 
    qsel = QSelection.where(quiz_id: self.id).order(:index)
    return qsel.map(&:question).map(&:subparts).flatten
  end

  def assign_to (students, publish = false) 
    # students : an array of selected students from the DB

    # Mappings to take care of :
    #   1. quiz <-> testpaper
    #   2. student <-> testpaper
    #   3. graded_response <-> testpaper
    #   4. graded_response <-> student

    past = Testpaper.where(:quiz_id => self.id).map(&:id)
    ntests = past.count
    assigned_name = "##{ntests + 1} - #{Date.today.strftime('%B %d, %Y')}" 

    testpaper = self.testpapers.build name: assigned_name, takehome: publish # (1) 
    picked_questions = QSelection.where(:quiz_id => self.id).order(:start_page)

    students.each do |s|
      testpaper.students << s # (2) 
      picked_questions.each do |q|
        subparts = Subpart.where(question_id: q.question_id).order(:index)
        subparts.each do |p|
          g = GradedResponse.new(q_selection_id: q.id, student_id: s.id, subpart_id: p.id)
          testpaper.graded_responses << g
        end
      end
    end # student loop 

    return nil if testpaper.students.empty?
    testpaper = testpaper.save ? testpaper : nil
    return testpaper
  end 

  def preview_images(restricted = false)
    uid = encrypt(self.id,7)
    return [*1..self.span?].map{ |pg| "quiz/#{uid}/preview/page-#{pg}.jpeg" }
  end

  def teacher 
    Teacher.find self.teacher_id
  end 

  def span?
    return self.span unless self.span.nil?

    last = QSelection.where(:quiz_id => self.id).order(:index).last.end_page
    self.update_attribute :span, last
    return last
  end

  def lay_it_out(qids = [])
=begin
    This method defines as much of the layout as can be done reliably
    and cleanly here. It does *not* calculate shadows as for doing that 
    one needs to see not just a questions predecessors on a page 
    but also its successors

    'qids' is an array of question_ids. If its NOT blank, then it means 
    that the passed questions have to be laid out in the order given 
    in the array. Do NOT count on there being too many sanity checks on 
    qids in the code below

    Passing qids is highly NOT recommended. Do this only if you know 
    what you are doing
=end
    questions = qids.blank? ? self.questions.sort{ |m,n| m.length? <=> n.length? } : 
                              Question.where(id: qids).sort{ |m,n| qids.index(m.id) <=> qids.index(n.id) }

    qsel = QSelection.where(quiz_id: self.id)
    curr_page = 1
    space_left = 1
    page_breaks = [] # stores the 'curr_subparts' after which page-breaks must be inserted
    version_triggers = []

    total_subparts = self.subparts.count
    curr_subpart = 0 # 0-indexed to be in-sync with what \setPageBreaks expects in TeX 
    curr_question = 1

    for j in questions
      y = qsel.where(question_id: j.id).first
      next if y.nil?
      y.update_attributes start_page: curr_page, index: curr_question

      sbp = j.subparts.order(:index)
      multipart = sbp.count > 1
      breaks_within_question = []

      for k in sbp
        required = k.length?
        fits = (required <= space_left) || (required == 1 && space_left >= 0.5)
        unless fits  
          page_breaks.push(curr_subpart - 1)
          breaks_within_question.push(k.index - 1) if multipart
          curr_page += 1
          space_left = 1 - required
        else 
          space_left -= required 
        end
        curr_subpart += 1
      end # of laying out subparts 

      curr_question += 1
      version_triggers.push(curr_subpart - 1) # the last subpart, now that we are moving to next question
      y.update_attribute :end_page, curr_page
      y.update_attribute(:page_breaks, breaks_within_question.map(&:to_s).join(',')) unless breaks_within_question.blank?
    end # of laying questions
    return page_breaks, version_triggers
  end

  def layout?(for_wsdl = true)
=begin
    The structure of the returned hash depends on 'for_wsdl'

    If true, then its [ { :number => page, :question => [ { :id => uid } ... ] } ... ]
    Otherwise, its [ { :page => page, :question => [ <db-ids> ... ] } ... ]

    The latter form is useful when distributing work
=end

    selected = QSelection.where(:quiz_id => self.id).order(:start_page)
    last = selected.last.end_page 
    layout = [] # return value

    [*1..last].each do |page|
      q_on_page = selected.where(:start_page => page)

      if for_wsdl 
        on_page = q_on_page.map{ |m| { :id => m.question.uid } } 
      else
        on_page = q_on_page.map(&:question_id)
      end
      layout.push( { :number => page, :question => on_page } )
    end
    return layout
  end

  def compile_tex(page_breaks = [], version_triggers = [])
    teacher = self.teacher 

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['build_quiz']}" 

    response = SavonClient.request :wsdl, :buildQuiz do  
      soap.body = {
        quiz: { id: self.id, name: self.latex_safe_name, value: encrypt(self.id, 7) },
        teacher: { id: teacher.id, name: teacher.name },
        questions:  QSelection.where(quiz_id: self.id).order(:index).map(&:question).map{ |q| { id: q.uid } },
        breaks: page_breaks,
        version_triggers: version_triggers
      }
     end # of response 

     # sample response : {:build_quiz_response=>{:manifest=>{:root=>"/home/gutenberg/bank/mint/15"}}}
     return response.to_hash[:build_quiz_response]
  end # of method

  def shred_pdfs
    # Going forward, this method would issue a Savon request to the
    # 'printing-press' asking it to delete PDFs of testpapers generated
    # for this Quiz - both composite & per-student 
    return true
  end

  def pending_scans(examiner, page)
    @pending = GradedResponse.ungraded.with_scan.in_quiz(self.id).assigned_to(examiner).on_page(page)
    @pending = @pending.sort{ |m,n| m.index? <=> n.index? }

    @scans = @pending.map(&:scan).uniq.sort
    @students = Student.where( :id => @pending.map(&:student_id).uniq )
    return @students, @pending, @scans
  end

  def clone?
    return self if self.testpaper_ids.count == 0
    
    # there should be just one editable clone at a time
    clone = Quiz.where(:parent_id => self.id).select{ |m| m.testpaper_ids.count == 0 }.first
    return clone
  end

  def clone(teacher = nil)
=begin
    A quiz is cloned under the following situations 
      1. if it is being edited but cannot be changed in place (because of existing worksheets)
      2. a newly registered teacher is doing the quick-trial

      'teacher' != nil => quiz being cloned for a teacher different from the original author
=end
    selections = QSelection.where(:quiz_id => self.id).map(&:question_id)

    if teacher.nil?
      name = "#{self.name} (edited)"
      author = self.teacher_id
    else
      name = self.name
      author = teacher
    end

    copy = Quiz.new name: name, teacher_id: author, question_ids: selections, 
                    num_questions: selections.count, parent_id: self.id 

    if copy.save 
      ret = teacher.nil? ? "A new version - #{name} - has been created" : copy 
    else
      ret = nil
    end
    return ret
  end

  def remove_questions(question_ids)
    return self.add_remove_questions question_ids, false
  end

  def add_questions(question_ids)
    return self.add_remove_questions question_ids, true 
  end


  def add_remove_questions(question_ids, add = false)
    return false if question_ids.count == 0

    clone = self.clone?
    title = "#{question_ids.count} question(s) #{add ? 'added' : 'removed'}"
    msg = clone.nil? ? self.clone : ""

    job = Delayed::Job.enqueue EditQuiz.new(self, question_ids, add), priority: 0, run_at: Time.zone.now
    estimate = minutes_to_completion job.id
    msg += " PDF will be ready within #{estimate} minute(s)"
    return title, msg
  end

  def latex_safe_name
    safe = self.name 
    # The following 10 characters have special meaning in LaTeX and hence need to 
    # be escaped with a backslash before typesetting 

    ['#', '$', '&', '^', '%', '\\', '_', '{',  '}', '~'].each do |m|
      safe = safe.gsub m, "\\#{m}"
    end 
    return safe
  end

  def compiling?
    # If compilation fails, then the Quiz object itself is destroyed. In which case
    # there is no way this object method can be called

    # job_id = -1 => default initial state
    #        > 0 => queued => compiling
    #        = 0 => compilation completed
    return self.job_id > 0
  end

  def uid
    return encrypt(self.id, 7)
  end

end # of class

