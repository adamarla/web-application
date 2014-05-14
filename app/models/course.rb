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

  validates :title, presence: true

  has_many :freebies, dependent: :destroy
  has_many :lessons, through: :freebies

  has_many :takehomes, dependent: :destroy 
  has_many :quizzes, through: :takehomes

  after_create :seal

  def description?
    return self.description || "No description"
  end 

  def quizzes 
    # Returns the list of quizzes currently included in the quiz 
    # - ordered by index
    Takehome.where(course_id: self.id).order(:index).map(&:quiz)
  end 

  def lessons
    # Returns the list of lessons currently included in the quiz 
    # - ordered by index
    Freebie.where(course_id: self.id).order(:index).map(&:lesson)
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

#################################################################
  
  private 
      
      def seal 
        d = self.description.blank? ? nil : self.description
        self.update_attributes(description: d)
      end 

end # of class
