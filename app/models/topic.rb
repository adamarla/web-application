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
    Syllabus.where(:topic_id => self.id).each do |m|
      m.update_attribute :topic_id, target
    end

    # Now, you may destroy self
    self.destroy 
  end

  private 

    def humanize_name
      self.name = self.name.strip.humanize
    end

end
