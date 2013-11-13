# == Schema Information
#
# Table name: milestones
#
#  id         :integer         not null, primary key
#  index      :integer         default(-1)
#  course_id  :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Milestone < ActiveRecord::Base
  belongs_to :course

  # Milestone -> Coursework -> Quiz
  has_many :coursework
  has_many :quizzes, through: :coursework 
  
  # Milestone -> Lecture -> Lesson
  has_many :lectures
  has_many :lessons, through: :lectures

  def self.in_course(id)
    where(course_id: id).order(:index)
  end

  def name
    return "#{self.course_id}.#{self.index}"
  end

end
