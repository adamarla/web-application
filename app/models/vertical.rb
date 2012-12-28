# == Schema Information
#
# Table name: verticals
#
#  id         :integer         not null, primary key
#  name       :string(30)
#  created_at :datetime
#  updated_at :datetime
#

class Vertical < ActiveRecord::Base
  has_many :topics 
  validates :name, :presence => true
  validates :name, :uniqueness => true
  before_validation :humanize_name

  def print_name
    n_questions = Question.on_topic(self.topics.map(&:id)).count
    return "#{self.name} (#{n_questions})"
  end

  private 

    def humanize_name
      self.name = self.name.strip.humanize
    end

end
