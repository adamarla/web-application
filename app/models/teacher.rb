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
  has_one :account, :as => :loggable
  has_one :trial_account

  has_many :faculty_rosters
  has_many :sektions, :through => :faculty_rosters

  has_many :grades
  has_many :yardsticks, :through => :grades

  has_many :specializations
  has_many :subjects, :through => :specializations

  has_many :favourites, :dependent => :destroy

  validates :first_name, :last_name, :presence => true  

  before_save  :humanize_name
  after_create :build_grade_table
  after_save   :reset_login_info

  # When would one want to 'destroy' a teacher? And what would it mean? 
  # 
  # My guess is that a teacher should NEVER be 'destroyed' even if he/she 
  # is expected to quit teaching for the forseeable future (say, due to child birth). 
  # You never know, he/she might just get back to teaching. Moreover, the teacher's 
  # past record can be a good reference for the new school.

  #after_validation :setup_account, :if => :first_time_save?
  before_destroy :destroyable? 

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

  def add_to_favourites(question_id)
    m = Favourite.where(:teacher_id => self.id, :question_id => question_id)
    return unless m.empty? # no double-addition
    self.favourites.create :question_id => question_id # will also save to the DB
  end

  def remove_from_favourites(question_id)
    m = Favourite.where(:teacher_id => self.id, :question_id => question_id)
    return if m.empty?
    m = m.first
    self.favourites.delete m # will also destroy because of the :dependent => :destroy
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
