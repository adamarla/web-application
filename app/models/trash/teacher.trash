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
#  indie      :boolean         default(TRUE)
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
  has_many :suggestions, dependent: :destroy
  has_many :courses
  has_many :lessons
  has_many :aggr_by_topics, as: :aggregator

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

  def rubric_id? 
    own = Rubric.where(account_id: self.account.id, active: true)
    ret = own.blank? ? Rubric.where(standard: true, active: true) : own
    return (ret.blank? ? nil : ret.first.id)
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

  def new_to_the_site?
    (self_made_quizzes.count < 1)
  end

  def send_digest(n, exams, quizzes)
    ret = [] 
    quizzes.select{ |j| j.teacher_id == self.id }.each do |q|
      h = {} 
      h[:q] = q.name 
      exams.select{ |k| k.quiz_id == q.id }.each do |e|
        h[:e] = e.sektion.name 
        w = e.worksheets 
        for k in [:none, :partially, :fully]
          h[k] = w.map{ |v| v.received?(k)}.count(true)
        end 
        h[:mean] = "#{e.mean?}/#{q.total?}"
      end 
      ret.push h
    end 
    Mailbot.delay.teacher_digest(self, n, ret)
  end 

  def send_upload_summary(q,e,w,tryouts) # come from controller::send_digest. Uniquified
    q = q.select{ |j| j.teacher_id == self.id }

    # Now, we need to build the array that will be passed to the mailer to render as a table.
    ret = [] 
    q.each_with_index do |qz, a|
      e.select{ |j| j.quiz_id == qz.id }.each_with_index do |exm, b| 
        w.select{ |j| j.exam_id == exm.id }.each_with_index do |ws, c| 
          h = {} 
          if c > 0 # not the first student => quiz, sektion same as first listed classmate! 
            h[:q] = "" 
            h[:e] = "" 
          else
            h[:q] = b > 0 ? "" : qz.name 
            h[:e] = exm.sektion.name 
          end 
          h[:s] = ws.student.name 
          h[:uploads] = tryouts.select{ |j| j.worksheet_id == ws.id }.sort_by{ |n| n.id }.map(&:name?).join(',')
          ret.push h
        end # worksheets 
      end # exams 
    end # quizzes
    Mailbot.delay.upload_summary(self, ret) 
    #Mailbot.upload_summary(self, ret).deliver
  end 

#####  PRIVATE ######################

  private 
    
    def destroyable? 
      return false 
    end 

    def first_time_save? 
      self.new_record? || !self.account
    end 

    def self_made_quizzes
      qids = Quiz.where(teacher_id: self.id).map(&:id)
      self_made = qids - [PREFAB_DEMO_QUIZ] - PREFAB_QUIZ_IDS
      Quiz.where(id: self_made)
    end 

end # of class 
