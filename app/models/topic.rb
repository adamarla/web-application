# == Schema Information
#
# Table name: topics
#
#  id          :integer         not null, primary key
#  name        :string(50)
#  created_at  :datetime
#  updated_at  :datetime
#  vertical_id :integer
#

#     __:has_many____      ____:has_many___    ____:has_many__
#    |               |    |                |  |               |
#  Subject --------> Vertical -----------> Topics ---------> Questions
#    |               |  |                  |   |               |
#    |__:belongs_to__|  |___:has_many______|   |__:belongs_to__|
#    

class Topic < ActiveRecord::Base
  validates :name, :presence => true
  validates :name, :uniqueness => true

  has_many :syllabi
  belongs_to :vertical

  #before_validation :humanize_name

  def benchmark(type = :senior)
    # Returns the weighted average marks for questions on given topic
    # for a given grade level - junior(1), middle(2) or senior(3)

    # target_difficulty = type == :senior ? 3 : (type == :junior ? 1 : 2)
    # qids = Question.on_topic(self.id).difficulty(target_difficulty).map(&:id)
    qids = Question.on_topic(self.id).map(&:id)
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
    # Now, you may destroy self
    self.destroy 
  end

  private 

    def humanize_name
      self.name = self.name.strip.humanize
    end

end
