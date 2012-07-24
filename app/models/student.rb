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

  validates :first_name, :last_name, :presence => true
  before_save :humanize_name
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

  def username?
    self.account.username
  end 
  
  def name (who_wants_to_know = :guest) 
    case who_wants_to_know 
      when :teacher, :admin, :school
        return "#{self.first_name} #{self.last_name} (#{self.username?})"
      else 
        return "#{self.first_name} #{self.last_name}"
    end
  end 

  def print_name
    sektion = Sektion.where(:id => self.sektion_id).select('name,klass').first
    return "#{self.first_name} #{self.last_name} (#{sektion.klass} - #{sektion.name})"
  end

  def name=(name)
    split = name.split
    self.first_name = split.first
    self.last_name = split.last
  end

  def teachers
    Teacher.joins(:sektions).where('sektions.id = ?', self.sektion_id)
  end 

  def quiz_ids
    # Return the list if Quiz IDs this student has taken
    responses = GradedResponse.where(:student_id => self.id)
    selection_ids = responses.select(:q_selection_id).map(&:q_selection_id)
    quiz_ids = QSelection.where(:id => selection_ids).select(:quiz_id).map(&:quiz_id).uniq
    return quiz_ids
  end

  def responses(testpaper_id)
    a = GradedResponse.of_student(self.id).in_testpaper(testpaper_id).with_scan
    return a.sort{ |m,n| m.q_selection.index <=> n.q_selection.index }
  end

  def proficiency?(topic_id)
    # Return values:
    #    0: no data or not enough data
    #    1: pink => conceptual problems
    #    2: orange => basic understanding but needs more work 
    #    3: green => doing fine/well
    g = GradedResponse.of_student(self.id).graded.on_topic(topic_id)
    return 0 if g.count == 0
    weighted = g.map{ |m| m.q_selection.question.marks? * m.grade.yardstick.colour }.inject(:+).to_f
    total = g.map{ |m| m.q_selection.question.marks? }.inject(:+)
    average = (weighted/total).round(2)
    #ceiling = average.ceil
    #average = (ceiling - average) > 0.15 ? average.floor : ceiling
    return average
  end

  private 
    def destroyable? 
      return false 
    end 

    def humanize_name
      self.first_name = self.first_name.humanize
      self.last_name = self.last_name.humanize
    end 

    def reset_login_info
      new_prefix = username_prefix_for(self, :student)
      u = self.account.username.sub(/^\w+\./, "#{new_prefix}.")
      self.account.update_attributes :username => u
    end

end # of class 
