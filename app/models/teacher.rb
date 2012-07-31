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
  has_many :quizzes, :dependent => :destroy 
  belongs_to :school 
  has_one :account, :as => :loggable, :dependent => :destroy
  has_one :trial_account, :dependent => :destroy

  has_many :grades, :dependent => :destroy
  has_many :yardsticks, :through => :grades

  has_many :specializations, :dependent => :destroy
  has_many :subjects, :through => :specializations

  has_many :favourites, :dependent => :destroy
  has_many :suggestions

  validates :first_name, :last_name, :presence => true  

  before_save  :humanize_name
  after_create :build_grade_table, :generate_suggestion_form
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
    s = all ? s.where(:exclusive => false) : s.where(:teacher_id => self.id)
    return s.order(:klass)
  end

  def students( all = true )
    sektions = self.sektions all 
    student_ids = StudentRoster.where(:sektion_id => sektions.map(&:id)).map(&:student_id).uniq
    return Student.where(:id => student_ids)
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
      status = response[:manifest].blank? ? :bad_request : :ok
      if status == :bad_request 
        @quiz.destroy
      else
        # The atm-key is the randomized access point to this quiz in mint/
        atm_key = Quiz.extract_atm_key response[:manifest][:root]
        @quiz.update_attribute :atm_key, atm_key
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

  def name( who_wants_to_know = :guest )
    case who_wants_to_know 
      when :teacher, :admin, :school
        return "#{self.first_name} #{self.last_name} (#{self.username?})"
      else 
        return "#{self.first_name} #{self.last_name}"
    end
  end 

  def name=(name)
    split = name.split
    self.first_name = split.first
    self.last_name = split.last
  end

  def print_name
    return "#{self.first_name} #{self.last_name}"
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
    sektions = FacultyRoster.where(:teacher_id => self.id).map(&:sektion_id)
    klasses = Sektion.where(:id => sektions).map(&:klass).uniq
    subjects = Specialization.where(:teacher_id => self.id).map(&:subject_id)
    board = self.school.board_id
    return Course.where :board_id => board, :klass => klasses, :subject_id => subjects
  end

  def testpapers
    quiz_ids = Quiz.where(:teacher_id => self.id).order(:klass).map(&:id)
    @testpapers = Testpaper.where(:quiz_id => quiz_ids).order('created_at DESC')
  end

  def build_grade_table
    Yardstick.select('id, default_allotment').each do |y|
      grade = self.grades.new :allotment => y.default_allotment, :yardstick_id => y.id
      break if !grade.save
    end
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
  
  def generate_suggestion_form
    # At any given time, there is at most one copy of suggestion.tex in front-desk/.
    # Hence, if > 1 requests for generating suggestion form are sent (after_create), then 
    # each subsequent request will overwrite the suggestion.tex from the previous request.
    # And therefore, to keep things clean, we have to process each request individually
    # by placing it in the queue
    Delayed::Job.enqueue BuildSuggestionForm.new(self), :priority => 0, :run_at => Time.zone.now 
  end

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

    def humanize_name
      self.first_name = self.first_name.humanize
      self.last_name = self.last_name.humanize
    end 


end
