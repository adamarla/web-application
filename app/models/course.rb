# == Schema Information
#
# Table name: courses
#
#  id         :integer         not null, primary key
#  name       :string(50)
#  teacher_id :integer
#  created_at :datetime
#  updated_at :datetime
#  price      :decimal(5, 2)
#

class Course < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :teacher
  has_many :milestones

  def available_quizzes
=begin
  Returns list of quizzes: 
    1. Made by the instructor of this course 
    2. and which are NOT being used in this course
=end
    all = Quiz.where(teacher_id: self.teacher_id).map(&:id)
    used = Coursework.where(milestone_id: self.milestone_ids).map(&:quiz_id)
    return Quiz.where(id: (all - used)).order(:name)
  end

  def available_lessons
=begin
  Returns list of lessons: 
    1. Made by any instructor - and not just the one for the course 
    2. and which are NOT being used in this course
=end
    all = Lecture.all.map(&:lesson_id)
    used = Lecture.where(milestone_id: self.milestone_ids).map(&:lesson_id)
    return Lesson.where(id: (all - used))
  end

end
