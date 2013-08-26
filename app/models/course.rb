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
  after_create :add_milestones

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
    all = Lesson.all.map(&:id) 
    used = Lecture.where(milestone_id: self.milestone_ids).map(&:lesson_id)
    return Lesson.where(id: (all - used))
  end

  def add_milestones
    for i in [*1..3]
      m = self.milestones.create index: i
    end
  end

  def lesson_ids
    # returns list of lesson_ids within all milestones
    Lecture.where(milestone_id: self.milestone_ids).map(&:lesson_id).uniq
  end

  def quiz_ids 
    # returns list of quiz_ids within all milestones
    Coursework.where(milestone_id: self.milestone_ids).map(&:quiz_id).uniq
  end

  def has_asset(id, is_lesson)
    asset_ids = is_lesson ?  self.lesson_ids : self.quiz_ids
    return asset_ids.include? id
  end

  def attach(id, is_lesson, milestone_index) 
    # Ensure that the same asset is ** not ** included in the same course twice
    return false if self.has_asset id, is_lesson 

    m = Milestone.in_course(self.id).where(index: milestone_index).first
    return false if m.nil?

    if is_lesson
      m.lesson_ids = (m.lesson_ids + [id]).uniq
    else
      m.quiz_ids = (m.quiz_ids + [id]).uniq
    end
  end 

  def detach(id, is_lesson) 
    return false unless self.has_asset id, is_lesson 
    m = nil

    for m in self.milestones 
      ids = is_lesson ? m.lesson_ids : m.quiz_ids
      break if ids.include? id
    end

    return false if m.nil? # Should never, ever happen !!!

    if is_lesson
      m.lesson_ids = (m.lesson_ids - [id]).uniq
    else
      m.quiz_ids = (m.quiz_ids - [id]).uniq
    end
  end 


end
