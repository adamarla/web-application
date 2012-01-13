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
#

class GradedResponse < ActiveRecord::Base
  belongs_to :q_selection
  belongs_to :student
  belongs_to :examiner
  belongs_to :grade

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

  # [:all] ~> [:admin, :cron]
  # [:grade_id] ~> [:examiner, :teacher]
  #attr_accessible
end
