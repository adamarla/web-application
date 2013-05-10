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

  has_many :q_selections, :dependent => :destroy
  has_many :questions, :through => :q_selections

  has_many :testpapers, :dependent => :destroy

  validates :teacher_id, :presence => true, :numericality => true
  validates :name, :presence => true
  
  #before_validation :set_name, :if => :new_record?
  after_create :lay_it_out
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
    q = QSelection.where(:quiz_id => self.id).select('index, question_id').sort{ |m,n| m.index <=> n.index }
    q = q.map{ |m| Question.find m.question_id }
    return q.map{ |m| m.subparts.order(:index) }.flatten
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
    testpaper = self.testpapers.build :name => assigned_name, :inboxed => publish # (1)
    picked_questions = QSelection.where(:quiz_id => self.id).order(:start_page)

    students.each do |s|
      # taken = AnswerSheet.where(:student_id => s.id).map(&:testpaper_id)
      # Don't issue the same quiz to the same students
      # next unless (taken & past).blank? 

      testpaper.students << s # (2) 
      picked_questions.each do |q|
        subparts = Subpart.where(:question_id => q.question_id).order(:index)
        subparts.each do |p|
          g = GradedResponse.new(:q_selection_id => q.id, :student_id => s.id, :subpart_id => p.id)
          testpaper.graded_responses << g
        end
      end
    end # student loop 

    return nil if testpaper.students.empty?
    testpaper = testpaper.save ? testpaper : nil
    return testpaper
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

  def lay_it_out
=begin
    Layout in two steps:
      1. First, layout all the standalone questions. Try to waste as 
         little space as possible
      2. Then, layout out the multipart questions. These questions take a 
         whole number of pages
=end
    questions = Question.where(:id => self.question_ids)
    standalone = questions.standalone.sort{ |m,n| m.span? <=> n.span? }
    multipart = questions - standalone

    spans = standalone.map(&:span?)
    start = 0 
    stop = -1
    last = spans.length - 1
    layout = []

    # Code below tries to slice 'spans' into chunks where the sum of spans in 
    # each chunk <= 1. A bit inefficient in terms of iterations but easy to read
    while (start <= last)
      [*start..last].each do |i|
        sum = spans.slice(start..i).inject(:+)
        stop = i if ( sum == 1 || i == last )
        stop = i-1 if sum > 1
        if (stop != -1)
          layout.push standalone.slice(start..stop).map(&:id)
          break 
        end
      end
      start = stop + 1
      stop = -1
    end

    current_index = 1 
    layout.each_with_index do |ids, j|
      QSelection.where(:question_id => ids, :quiz_id => self.id).each_with_index do |s,k|
        s.update_attributes :start_page => j + 1, :end_page => j + 1, :index => current_index
        current_index += 1
      end
    end # of while 
    
    # Now, the multipart questions 
    spans = multipart.map(&:span?)
    current_page = layout.length + 1
    last_standalone = standalone.count

    spans.each_with_index do |span, index|
      qid = multipart[index].id
      s = QSelection.where(:question_id => qid, :quiz_id => self.id).first
      s.update_attributes :start_page => current_page, :end_page => (current_page + span - 1), 
                          :index => (last_standalone + index + 1)
      current_page += span
    end
  end # lay_it_out

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

  def compile_tex
    teacher = self.teacher 

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['build_quiz']}" 

    response = SavonClient.request :wsdl, :buildQuiz do  
      soap.body = { 
         :quiz => { :id => self.id, :name => self.latex_safe_name, :value => encrypt(self.id,7) },
         :teacher => { :id => teacher.id, :name => teacher.name },
         :page => self.layout?
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

  # Returns the list of micro-topics touched upon in this Quiz - as an array of indices
  def micros
    self.questions.map{|q| q.topic_id}.uniq
  end

  def pending_questions
    a = GradedResponse.in_quiz(self.id).ungraded
  end

  def pending_pages(examiner_id)
    pending = GradedResponse.ungraded.with_scan.in_quiz(self.id).assigned_to(examiner_id)
    @pages = pending.map(&:page?).uniq.sort
    return @pages
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

  def clone
    # Remember: The only reason a quiz needs to be cloned is if its being edited
    selections = QSelection.where(:quiz_id => self.id).map(&:question_id)
    name = "#{self.name} (edited)"

    copy = Quiz.new :name => name, :teacher_id => self.teacher_id, 
                    :question_ids => selections, :num_questions => selections.count, 
                    :parent_id => self.id 
    msg = copy.save ? "The quiz needed to be cloned first and a new version - #{name} - has been created." : nil
    return msg
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

    job = Delayed::Job.enqueue EditQuiz.new(self, question_ids, add), :priority => 0, :run_at => Time.zone.now
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

