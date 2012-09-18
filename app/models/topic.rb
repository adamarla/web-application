# == Schema Information
#
# Table name: topics
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  vertical_id :integer
#

#     __:has_many___      __:has_many___   ____:has_many__
#    |              |    |              | |               |
#  Board --------> Courses ---------> Sp.Topics ---------> Questions
#    |               |  |               | |               |
#    |__:belongs_to__|  |___:has_many___| |__:belongs_to__|
#    

class Topic < ActiveRecord::Base
  validates :name, :presence => true
  validates :name, :uniqueness => true

  has_many :courses, :through => :syllabi
  has_many :syllabi
  belongs_to :vertical

  before_validation :humanize_name

  def difficulty_in(course_id)
    entry = Syllabus.where(:course_id => course_id, :topic_id => self.id).first
    return entry.nil? ? 0 : entry.difficulty
  end 

  def question_bank_health_for(type = :senior)
    # Returns the weighted average marks for questions on given topic
    # for a given grade level - junior(1), middle(2) or senior(3)

    target_difficulty = type == :senior ? 3 : (type == :junior ? 1 : 2)
    qids = Question.on_topic(self.id).difficulty(target_difficulty).map(&:id)
    subparts = Subpart.where(:question_id => qids)
    return 0 if subparts.count == 0

    score = 0
    [*1..6].each do |marks|
      score += (marks * subparts.where(:marks => marks).count)
    end
    weighted = (score / subparts.count.to_f).round(2)
    return weighted
  end

  def print_name
    n_questions = Question.on_topic(self.id).count
    return "#{self.name} (#{n_questions})"
  end

  def mv(target)
    # Like the UNIX mv command, changes references to self anywhere to target (topic)
    # Unlike unix mv, however, the target should exist. Note that self is destroyed also
    return false if Topic.where(:id => target).empty?

    # Change question topic_ids 
    Question.where(:topic_id => self.id).each do |m|
      m.update_attribute :topic_id, target
    end

    # Change syllabus entries for any course that previously contained self
    # Look out for double entries, that is, courses that have both self and target

    courses = Syllabus.where(:topic_id => self.id).map(&:course_id)
    Course.where(:id => courses).each do |m| 
      s = Syllabus.where(:course_id => m.id)
      if s.where(:topic_id => target).empty? 
        orig = s.where(:topic_id => self.id).first
        orig.update_attribute :topic_id, target
      else # both target and self in syllabus 
        topics = s.map(&:topic_id)
        m.topic_ids = (topics - [self.id])
      end
    end 

    # Now, you may destroy self
    self.destroy 
  end

  private 

    def humanize_name
      self.name = self.name.strip.humanize
    end

end
