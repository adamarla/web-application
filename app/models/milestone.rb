# == Schema Information
#
# Table name: milestones
#
#  id         :integer         not null, primary key
#  index      :integer         default(-1)
#  course_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Milestone < ActiveRecord::Base
  belongs_to :course

  # Milestone -> Coursework -> Quiz
  has_many :coursework
  has_many :quizzes, through: :coursework 
  
  # Milestone -> Lecture -> Lesson
  has_many :lectures
  has_many :lessons, through: :lectures


  after_create :push_to_last 

  def self.in_course(id)
    where(course_id: id).order(:index)
  end

  def lessons
    ids = Lecture.where(milestone_id: self.id).map(&:lesson_id).uniq
    return Lesson.where(id: ids)
  end

  def quizzes
    ids = Coursework.where(milestone_id: self.id).map(&:quiz_id).uniq
    return Quiz.where(id: ids)
  end

  def push_to_last
    last = Milestone.in_course(self.course_id).where{ index != -1 }.order(:index) 
    index = last.nil? ? 1 : last.index + 1
    self.update_attribute :index, index
  end 

  def name
    return "#{self.course_id}.#{self.index}"
  end

end
