# == Schema Information
#
# Table name: quizzes
#
#  id            :integer         not null, primary key
#  teacher_id    :integer
#  created_at    :datetime
#  updated_at    :datetime
#  num_questions :integer
#  name          :string(255)
#  klass         :integer
#  subject_id    :integer
#  atm_key       :integer
#  total         :integer
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

  def assign_to (students) 
    # students : an array of selected students from the DB

    # Mappings to take care of :
    #   1. quiz <-> testpaper
    #   2. student <-> testpaper
    #   3. graded_response <-> testpaper
    #   4. graded_response <-> student

    # Testpaper names have the following form:
    #    Test #4: Apr 20, 2012

    ntests = Testpaper.where(:quiz_id => self.id).count
    assigned_name = "Worksheet ##{ntests + 1}: #{Date.today.strftime("%b %d, %Y")}"
    testpaper = self.testpapers.new :name => assigned_name # (1)
    questions = QSelection.where(:quiz_id => self.id).order(:start_page)

    students.each do |s|
      # Don't issue the same quiz to the same students
      next if s.quiz_ids.include? self.id

      testpaper.students << s # (2) 
      questions.each do |q|
        subparts = Subpart.where(:question_id => q.question.id).order(:index)
        subparts.each do |p|
          g = GradedResponse.new(:q_selection_id => q.id, :student_id => s.id, :subpart_id => p.id)
          testpaper.graded_responses << g
        end
        #testpaper.graded_responses << GradedResponse.new(:q_selection_id => q.id, :student_id => s.id) #(3) & (4)
      end
    end # student loop 

    if testpaper.students.empty?
      return {}
    else
      response = (self.save) ? testpaper.compile_tex : {}
      testpaper.destroy if response[:manifest].blank? 
      return response
    end
  end 

  def teacher 
    Teacher.find self.teacher_id
  end 

=begin
  def set_name
    subject = Subject.where(:id => self.subject_id).select(:name).first.name

    topics = Topic.where(:id => self.micros).map(&:name).join(', ')
    topics = topics.split[0...2].join(' ') # take the first 2 words only ...
    topics += ' ...'

    self.name = "#{self.klass}-#{subject}: #{topics}" 
  end 
=end
  
  def num_pages
    return QSelection.where(:quiz_id => self.id).order(:index).last.end_page
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

  def layout?
    # Sample layout --> [{ :number => 1, :question => [{:id => 1}, {:id => 2}] }]
    #
    # The form of the layout returned from here is determined by the WSDL. We 
    # really don't have much choice 

    j = self.q_selections.order(:start_page).select('question_id, end_page')
    last = j.last.end_page 
    layout = [] 

    [*1..last].each do |page|
      q_on_page = j.where(:start_page => page).map(&:question_id)
      q_on_page.each_with_index do |qid, index|
        # Previously, we sent the question's DB id. Now, we send the containing
        # folder's name - which really is just the millisecond time-stamp at 
        # which the question was created 

        uid = Question.where(:id => qid).first.uid 
        q_on_page[index] = { :id => uid }
      end
      layout.push( { :number => page, :question => q_on_page })
    end
    return layout
  end

  def compile_tex
    teacher = self.teacher 

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['build_quiz']}" 

    response = SavonClient.request :wsdl, :build_quiz do  
      soap.body = { 
         :quiz => { :id => self.id },
         :teacher => { :id => teacher.id, :name => teacher.name },
         :school => { :id => teacher.school.id, :name => teacher.school.name },
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

  def self.extract_atm_key(manifest_root)
    # manifest_root = http://< ... >:8080/atm/<atm-key>
    return manifest_root.split('/').last.to_i
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
    pending = GradedResponse.ungraded.with_scan.in_quiz(self.id).assigned_to(examiner).on_page(page)
    scans = pending.map(&:scan).uniq.sort

    @ret = {:scans => []}
    scans.each do |s|
      pick = pending.select{ |m| m.scan == s }.sort{ |m,n| m.q_selection.index <=> n.q_selection.index }
      indices = pick.map(&:id)
      type = pick.map{ |m| m.subpart.mcq }
      labels = pick.map(&:name?)
      (@ret[:scans]).push({:scan => s, :indices => indices, :mcq => type, :labels => labels}) unless indices.empty?
    end
    return @ret
  end

end # of class
