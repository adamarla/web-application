# == Schema Information
#
# Table name: courses
#
#  id          :integer         not null, primary key
#  title       :string(150)
#  description :text
#  teacher_id  :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Course < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :teacher

  has_many :freebies, dependent: :destroy
  has_many :lessons, through: :freebies

  has_many :takehomes, dependent: :destroy 
  has_many :quizzes, through: :takehomes

  def description?
    return self.description || "No description"
  end 

  def includeable_quizzes?
    # Quizzes that can be, but haven't yet been, included in this course
    ids = Quiz.where(teacher_id: self.teacher_id).map(&:id) - self.quizzes.map(&:id)
    return Quiz.where(id: ids)
  end 

  def includeable_lessons?
    # Lessons that can be, but haven't yet been, included in this course
    ids = Lesson.where(teacher_id: self.teacher_id).map(&:id) - self.lessons.map(&:id)
    return Lesson.where(id: ids)
  end

end
