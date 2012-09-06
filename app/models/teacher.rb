# == Schema Information
#
# Table name: teachers
#
#  id         :integer         not null, primary key
#  first_name :string(255)
#  last_name  :string(255)
#  created_at :datetime
#  updated_at :datetime
#  school_id  :integer
#

#     __:has_many_____     ___:has_many___  
#    |                |   |               | 
#  Teacher --------> Quizzes ---------> Questions 
#    |                |   |               | 
#    |__:belongs_to___|   |___:has_many___| 
#    

#     ___:has_many____     __:belongs_to___  
#    |                |   |                | 
# Teacher ---------> Grade ---------> Yardstick
#    |                |   |                | 
#    |__:belongs_to___|   |___:has_many____| 
#    

require 'rexml/document'
include REXML
include ApplicationUtil

class Teacher < ActiveRecord::Base
  belongs_to :school 

  has_one :account, :as => :loggable, :dependent => :destroy
  has_one :trial_account, :dependent => :destroy

  has_many :quizzes, :dependent => :destroy 

#  has_many :grades, :dependent => :destroy
#  has_many :yardsticks, :through => :grades

  has_many :specializations, :dependent => :destroy
  has_many :subjects, :through => :specializations

  has_many :favourites, :dependent => :destroy
  has_many :suggestions

  validates :first_name, :presence => true  

  after_create :generate_suggestion_form
  after_save   :reset_login_info

=begin
  Destroying a teacher should be a very rare event. It probably 
  shouldn't be done even if the teachers leaves the school. But then
  again, there might be situations - like when rationalizing DB records - 
  when one might have to destroy some teacher records 

  The point is - cross the bridge when it comes 
=end

  #after_validation :setup_account, :if => :first_time_save?
  #before_destroy :destroyable? 

  def klasses
    Specialization.where(:teacher_id => self.id).map(&:klass).uniq
  end 

  def sektions( all = true )
    # By default, this method returns all sektions that a teacher CAN teach - even if she 
    # doesn't teach some of them. To get only the sektions a teacher teaches, pass false to this method
    s = Sektion.in_school(self.school_id).of_klass(self.klasses)
    s = s - Sektion.where(:exclusive => true).where('teacher_id <> ?', self.id)
    s = s.where(:teacher_id => self.id) unless all
    return s.sort{ |m, n| m.klass <=> n.klass }
  end

  def students( all = true, filter = [] )
    # This method returns all the students a teacher can teach - even if she does 
    # actually teach them 
    students = Student.where(:school_id => self.school_id, :klass => self.klasses)
    return filter.empty? ? students : students.name_begins_with(filter)
  end 

  def suggested_questions( type = :completed ) # other possible values: :all, :wip, :just_in
    s_objs = Suggestion.where(:teacher_id => self.id)
    case type
      when :completed
        s_objs = s_objs.completed
      when :wip then 
        s_objs = s_objs.wip
      when :just_in then 
        s_objs = s_objs.just_in
    end # of case 

    q_ids = s_objs.map(&:question_ids).flatten.uniq
    return Question.where(:id => q_ids)
  end

  def build_quiz_with (name, question_ids, course)
    @quiz = Quiz.new :teacher_id => self.id, :question_ids => question_ids, 
                     :num_questions => question_ids.count, 
                     :subject_id => course.subject_id, :klass => course.klass,
                     :name => name

    # Ideally, one should ask for the TeX to be compiled before saving
    # @quiz into the database. But in this case, we need a quiz-ID and its layout 
    # before we can go in for TeX compilation. So, we save first and delete if TeX 
    # compilation fails

    status = @quiz.save ? :ok : :bad_request
    response = {}

    unless status == :bad_request
      response = @quiz.compile_tex
      manifest = response[:manifest]
      status = manifest.blank? ? :bad_request : :ok

      if status == :bad_request 
        @quiz.destroy
      else
        # The atm-key is the randomized access point to this quiz in mint/
        atm_key = Quiz.extract_atm_key manifest[:root] 
        span = manifest[:image].class == Array ? manifest[:image].count : 1
        @quiz.update_attributes :atm_key => atm_key, :span => span
        response = {:atm_key => atm_key, :name => @quiz.name }

        # Increment n_picked for each of the questions picked for this quiz
        Question.where(:id => question_ids).each do |m|
          m.increment_picked_count
        end 
      end
    end
    return response, status
  end

  def username?
    self.account.username
  end 

  def name
    return self.last_name.nil? ? self.first_name : "#{self.first_name} #{self.last_name}"
  end 

  def name=(name)
    split = name.split
    last = split.count - 1
    self.first_name = split.first.humanize

    if last > 0
      middle = split[1...last].map{ |m| m.humanize[0] }.join('.')
      self.last_name = middle.empty? ? "#{split.last.humanize}" : "#{middle} #{split.last.humanize}"
    end
  end

  def colleagues(strict = true)
=begin
    A colleague is defined as someone who is: 
      1. a teacher in the same school 
      2. teaches some or all of the same subjects 
      3. ( if strict = true ) and at the same grade levels 
=end
    ids = Teacher.where(:school_id => self.school_id).map(&:id) - [self.id]

    candidates = Specialization.where(:teacher_id => ids, :subject_id => self.subject_ids)
    candidates = strict ? candidates.where(:klass => self.klasses) : candidates

    return Teacher.where(:id => candidates.map(&:teacher_id).uniq)
  end

  def roster 
    # Yes, yes.. We could have gotten the same thing by simply calling self.sektions
    # But if we return an ActiveRelation, then we get the benefit of lazy loading
    Sektion.joins(:faculty_rosters).where('faculty_rosters.teacher_id = ?', self.id)
  end 

  def set_subjects(list_of_ids = [])
    list_of_ids.each_with_index { |a, index| list_of_ids[index] = a.to_i } 
    self.subjects = Subject.where :id => list_of_ids
  end

  def courses
    specializations  = Specialization.where :teacher_id => self.id
    board = self.school.board_id 
    
=begin
    What if teacher teaches 9th class maths and 10th class physics? 
    Should we then return:
      1. 9th class maths & 10th class physics only OR 
      2. 9th & 10th class maths & physics 

    For now, we will go with (1). But who knows, (2) might be better
=end
    course_ids = []
    [*9..12].each do |klass|
      subjects = specializations.where(:klass => klass).map(&:subject_id)
      course_ids += Course.where(:board_id => board, :klass => klass, :subject_id => subjects).map(&:id)
    end
    return Course.where(:id => course_ids)
  end

  def testpapers
=begin
    A teacher can access:
      1. any testpapers for her quizzes (obviously)
      2. any public/non-exclusive testpapers from her colleagues
          a. these testpapers would have been made public by the colleague herself.
             And so, its ok to show them
=end
    of_colleagues = Quiz.where(:teacher_id => self.colleagues.map(&:id))
    others = Testpaper.where(:exclusive => false, :quiz_id => of_colleagues.map(&:id)).map(&:id)

    my_own = Testpaper.where(:quiz_id => Quiz.where(:teacher_id => self.id)).map(&:id)
    total = (others + my_own).uniq

    @testpapers = Testpaper.where(:id => total).order('created_at DESC')
  end

  def like_question(question_id)
    m = Favourite.where(:teacher_id => self.id, :question_id => question_id)
    return unless m.empty? # no double-addition
    self.favourites.create :question_id => question_id # will also save to the DB
  end

  def unlike_question(question_id)
    m = Favourite.where(:teacher_id => self.id, :question_id => question_id)
    return if m.empty?
    m = m.first
    self.favourites.delete m # will also destroy because of the :dependent => :destroy
  end

#####  PRIVATE ######################

  private 
    
    def reset_login_info
      new_prefix = username_prefix_for self, :teacher
      u = self.account.username.sub(/^\w+\./, "#{new_prefix}.")
      self.account.update_attributes :username => u
    end

    def setup_account 
      self.build_account
    end 

    def destroyable? 
      return false 
    end 

    def first_time_save? 
      self.new_record? || !self.account
    end 

    def generate_suggestion_form
      # At any given time, there is at most one copy of suggestion.tex in front-desk/.
      # Hence, if > 1 requests for generating suggestion form are sent (after_create), then 
      # each subsequent request will overwrite the suggestion.tex from the previous request.
      # And therefore, to keep things clean, we have to process each request individually
      # by placing it in the queue
      Delayed::Job.enqueue BuildSuggestionForm.new(self), :priority => 5, :run_at => Time.zone.now 
    end

end # of class 
