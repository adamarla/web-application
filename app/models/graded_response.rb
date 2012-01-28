# == Schema Information
#
# Table name: graded_responses
#
#  id             :integer         not null, primary key
#  student_id     :integer
#  grade_id       :integer
#  scanned_image  :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  examiner_id    :integer
#  contested      :boolean         default(FALSE)
#  q_selection_id :integer
#  marks          :float
#  testpaper_id   :integer
#

class GradedResponse < ActiveRecord::Base
  belongs_to :student
  belongs_to :examiner
  belongs_to :grade
  belongs_to :q_selection
  belongs_to :testpaper

  validates :q_selection_id, :presence => true
  validates :student_id, :presence => true

  def self.on_page(page)
    # Returns all respones on passed page of all Quizzes
    where(:q_selection_id => QSelection.where(:page => page).map(&:id)) 
  end

  def self.in_quiz(id)
    # Responses to any question in a Quiz
    where(:q_selection_id => QSelection.where(:quiz_id => id).map(&:id)) 
  end

  def self.of_student(id)
    where(:student_id => id)
  end

  def self.to_question(id)
    where(:q_selection_id => QSelection.where(:question_id => id).map(&:id))
  end

  def self.unassigned
    where(:examiner_id => nil)
  end
  
  def self.ungraded
    where(:grade_id => nil)
  end

  def assign_grade(grade, examiner = nil)
    quiz = Quiz.where(:id => self.q_selection.quiz_id).first # response for which quiz?
    question = Question.where(:id => self.q_selection.question_id).first # to question? 

    return :bad_request if (quiz.nil? || question.nil?)

    teacher = Teacher.where(:id => quiz.teacher_id).first # quiz by which teacher?
    grade = Grade.where(:teacher_id => teacher.id, :yardstick_id => grade).first

    allotment = grade.nil? ? nil : grade.allotment
    marks = question.marks
    assigned = (marks * (allotment/100.0)).round(1)
    return (self.update_attributes(:grade_id => grade.id, :marks => assigned, :examiner_id => examiner) ? :ok : :bad_request)
  end

  # [:all] ~> [:admin, :cron]
  # [:grade_id] ~> [:examiner, :teacher]
  #attr_accessible
end
