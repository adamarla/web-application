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
    course = Course.find course_id
    unless course.nil? 
      in_syllabi = Syllabus.where(:course_id => course_id, :topic_id => self.id).first
      return in_syllabi.nil? ? 0 : in_syllabi.difficulty
    end 
    return 0
  end 

  def name
    n_questions = Question.where(:topic_id => self.id).count
    return "#{self.name} (#{n_questions})"
  end

  private 

    def humanize_name
      self.name = self.name.strip.humanize
    end

end
