# == Schema Information
#
# Table name: students
#
#  id          :integer         not null, primary key
#  guardian_id :integer
#  school_id   :integer
#  first_name  :string(255)
#  last_name   :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  klass       :integer
#

include ApplicationUtil

class Student < ActiveRecord::Base
  belongs_to :guardian
  belongs_to :school

  has_many :student_rosters, :dependent => :destroy 
  has_many :sektions, :through => :student_rosters

  # belongs_to :sektion
  has_one :account, :as => :loggable, :dependent => :destroy

  has_many :graded_responses
  has_many :quizzes, :through => :graded_responses

  has_many :answer_sheets
  has_many :testpapers, :through => :answer_sheets

  validates :first_name, :presence => true

  after_save  :reset_login_info

  # When should a student be destroyed? My guess, some fixed time after 
  # he/she graduates. But as I haven't quite decided what that time should
  # be, I am temporarily disabling all destruction

  before_destroy :destroyable? 

  def self.in_klass(klass)
    where(:klass => klass)
  end

  def self.in_school(id)
    where(:school_id => id)
  end

  def self.name_begins_with( allowed = [] )
    return if allowed.empty? 
    select{ |m| allowed.include? m.first_name[0] }
  end

  def username?
    self.account.username
  end 
  
  def abbreviated_name
    return self.last_name.nil? ? self.first_name : "#{self.first_name}-#{self.last_name[0]}"
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

  def teachers
    Teacher.joins(:sektions).where('sektions.id = ?', self.sektion_id)
  end 

  def quiz_ids
    t_ids = AnswerSheet.where(:student_id => self.id).map(&:testpaper_id)
    quiz_ids = Testpaper.where(:id => t_ids).map(&:quiz_id).uniq
    return quiz_ids
  end

  def marks_scored_in(testpaper_id)
    a = AnswerSheet.where(:student_id => self.id, :testpaper_id => testpaper_id).first 
    marks = a.nil? ? 0 : a.marks?
    return marks unless marks == 0
    return (self.absent_for_test?(testpaper_id) ? -1 : marks) 
  end

  def responses(testpaper_id)
    a = GradedResponse.of_student(self.id).in_testpaper(testpaper_id).with_scan
    return a.sort{ |m,n| m.q_selection.index <=> n.q_selection.index }
  end

  def expectations_met_in(topic_id)
    # Returns the weighted average percentage earned by a student on
    # a given topic on the questions his/her teacher set
    # Returns: a number in [0,1]
    g = GradedResponse.of_student(self.id).graded.on_topic(topic_id)
    sids = g.map(&:subpart_id).uniq

    earned = 0 
    [*1..6].each do |marks|
      having = g.select{ |m| m.subpart.marks == marks }
      next if having.count == 0
      avg = (having.map(&:system_marks).inject(:+) / having.count.to_f).round(2) # avg score on 'k' mark questions
      earned += avg
    end 
    max = Subpart.where(:id => sids).map(&:marks).uniq.inject(:+)
    weighted = max.nil? ? 0 : (earned/max).round(2)
  end 

  def absent_for_quiz?(quiz_id)
    tids = AnswerSheet.where(:student_id => self.id).map(&:testpaper_id)
    qids = Testpaper.where(:id => tids).map(&:quiz_id)
    took_test = qids.include? quiz_id 
    return true if !took_test

    g = GradedResponse.of_student(self.id).in_quiz(quiz_id).with_scan
    return g.count == 0
  end

  def absent_for_test?(testpaper_id)
    g = GradedResponse.of_student(self.id).in_testpaper(testpaper_id).with_scan
    return g.count == 0
  end

  def proficiency?(topic_id)
=begin
    Proficiency can be absolute or relative. Absolute proficiency takes into 
    account the toughness of the questions students tackled on a topic. If a teacher
    consistently picked easy questions, then even if the student got them all right,
    one really can't say the student is proficient

    Relative proficiency - on the other hand - normalizes marks student has earned
    over just the maximum marks a student could have earned over those questions - as 
    opposed to over the toughest questions he/she could have tackled

    This method returns the absolute proficiency
=end
    g = GradedResponse.of_student(self.id).graded.on_topic(topic_id)
    return 0 if g.count == 0

    marks = g.map(&:marks?).inject(:+).to_f
    max = 6 * g.count # 6 marks are for the toughest questions 
    score = (marks/max).round(2)
    return score
  end

  private 
    def destroyable? 
      return false 
    end 

    def reset_login_info
      new_prefix = username_prefix_for(self, :student)
      u = self.account.username.sub(/^\w+\./, "#{new_prefix}.")
      self.account.update_attributes :username => u
    end

end # of class 
