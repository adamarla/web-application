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
  
  before_validation :set_name, :if => :new_record?
  after_create :lay_it_out
  after_destroy :shred_pdfs

  def assign_to (students) 
    # students : an array of selected students from the DB

    # Mappings to take care of :
    #   1. quiz <-> testpaper
    #   2. student <-> testpaper
    #   3. graded_response <-> testpaper
    #   3. graded_response <-> student

    testpaper = self.testpapers.new :name => "#{Date.today.strftime "%B %d, %Y"}" # (1)
    questions = QSelection.where(:quiz_id => self.id).order(:page).select(:id)

    students.each do |s|
      # Don't issue the same quiz to the same students
      next if s.quiz_ids.include? self.id

      testpaper.students << s # (2) 
      questions.each do |q|
        testpaper.graded_responses << GradedResponse.new(:q_selection_id => q.id, :student_id => s.id) #(3) & (4)
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

  def set_name
    subject = Subject.where(:id => self.subject_id).select(:name).first.name

    topics = Topic.where(:id => self.micros).map(&:name).join(', ')
    topics = topics.split[0...2].join(' ') # take the first 2 words only ...
    topics += ' ...'

    self.name = "#{self.klass}-#{subject}: #{topics}" 
  end 
  
  def num_pages
    return QSelection.where(:quiz_id => self.id).order(:page).last.page
  end

  def lay_it_out
    questions = Question.where(:id => self.question_ids).order(:marks).order(:full_page).order(:half_page)
    page = 1
    pg_used = 0 # a fraction b/w 0 and 1
    index = 1

    questions.each_with_index do |q, index|
      pg_reqd = (q.mcq ? 0.25 : (q.half_page ? 0.5 : 1))
      if ((pg_used + pg_reqd) > 1)
        page += 1
        pg_used = pg_reqd # coz this new question will go on the next page 
      else
        pg_used += pg_reqd
      end 

      in_quiz = QSelection.where(:question_id => q.id, :quiz_id => self.id).first
      in_quiz.update_attributes :page => page, :index => index
    end
  end # lay_it_out

  def layout?
    # Sample layout --> [{ :number => 1, :question => [{:id => 1}, {:id => 2}] }]
    #
    # The form of the layout returned from here is determined by the WSDL. We 
    # really don't have much choice 

    j = self.q_selections.order(:page).select('question_id, page')
    last = j.last.page 
    layout = [] 

    [*1..last].each do |page|
      q_on_page = j.where(:page => page).map(&:question_id)
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
         :teacher => { :id => teacher.id, :name => teacher.print_name },
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

end # of class
