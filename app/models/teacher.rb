# == Schema Information
#
# Table name: teachers
#
#  id         :integer         not null, primary key
#  first_name :string(30)
#  last_name  :string(30)
#  created_at :datetime
#  updated_at :datetime
#  school_id  :integer
#  online     :boolean         default(FALSE)
#

#     __:has_many_____     ___:has_many___  
#    |                |   |               | 
#  Teacher --------> Quizzes ---------> Questions 
#    |                |   |               | 
#    |__:belongs_to___|   |___:has_many___| 
#    

require 'rexml/document'
include REXML
include ApplicationUtil

class Teacher < ActiveRecord::Base

  has_one :account, as: :loggable, dependent: :destroy
  has_many :quizzes, dependent: :destroy
  has_many :sektions, dependent: :destroy
  has_many :favourites, dependent: :destroy 
  has_many :suggestions
  has_many :courses
  has_many :lessons

  has_many :apprenticeships, dependent: :destroy 
  has_many :examiners, through: :apprenticeships

  validates :name, presence: true
  validates_associated :account

=begin
  Destroying a teacher should be a very rare event. It probably 
  shouldn't be done even if the teachers leaves the school. But then
  again, there might be situations - like when rationalizing DB records - 
  when one might have to destroy some teacher records 

  The point is - cross the bridge when it comes 
=end

  #before_destroy :destroyable? 

  def students 
    sk = Sektion.where(:teacher_id => self.id).map(&:id)
    sids = StudentRoster.where(:sektion_id => sk).map(&:student_id).uniq
    return Student.where(:id => sids)
  end 

  def benchmark(topic, level = :senior)
    target_difficulty = level == :senior ? 3 : (level == :junior ? 1 : 2)

    qids = QSelection.where(:quiz_id => self.quiz_ids).map(&:question_id) 
    questions = Question.where(:id => qids).on_topic(topic).difficulty(target_difficulty)
    return 0 if questions.count == 0 

    subparts = Subpart.where(:question_id => questions.map(&:id))
    score = 0 
    [*1..6].each do |marks|
      score += (marks * subparts.where(:marks => marks).count)
    end
    weighted = (score / subparts.count.to_f).round(2)
    return weighted
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

  def username?
    self.account.username
  end 

  def name
    return self.last_name.nil? ? self.first_name : "#{self.first_name} #{self.last_name}"
  end 

  def name=(name)
    name.gsub! /[\d\.\$\?\(\)\,#]+/,""
    split = name.strip.split
    last = split.count - 1
    self.first_name = split.first.humanize

    if last > 0
      middle = split[1...last].map{ |m| m.humanize[0] }.join('.')
      self.last_name = middle.empty? ? "#{split.last.humanize}" : "#{middle} #{split.last.humanize}"
    end
  end

  def roster 
    # Yes, yes.. We could have gotten the same thing by simply calling self.sektions
    # But if we return an ActiveRelation, then we get the benefit of lazy loading
    Sektion.joins(:faculty_rosters).where('faculty_rosters.teacher_id = ?', self.id)
  end 

  def worksheets
=begin
    A teacher can access:
      1. any worksheets for her quizzes (obviously)
      2. any public/non-exclusive worksheets from her colleagues
          a. these worksheets would have been made public by the colleague herself.
             And so, its ok to show them
=end
    of_colleagues = Quiz.where(:teacher_id => self.colleagues.map(&:id))
    others = Exam.where(:exclusive => false, :quiz_id => of_colleagues.map(&:id)).map(&:id)

    my_own = Exam.where(:quiz_id => Quiz.where(:teacher_id => self.id)).map(&:id)
    total = (others + my_own).uniq

    @worksheets = Exam.where(:id => total).order('created_at DESC')
  end

  def self_made_quizzes
    qids = Quiz.where(:teacher_id => self.id).map(&:id)
    self_made = qids - [PREFAB_DEMO_QUIZ] - PREFAB_QUIZ_IDS
    Quiz.where(:id => self_made)
  end 

  def new_to_the_site?
    (self.self_made_quizzes.count < 1)
  end

#####  PRIVATE ######################

  private 
    
    def destroyable? 
      return false 
    end 

    def first_time_save? 
      self.new_record? || !self.account
    end 

end # of class 
