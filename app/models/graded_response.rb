# == Schema Information
#
# Table name: graded_responses
#
#  id            :integer         not null, primary key
#  quiz_id       :integer
#  question_id   :integer
#  student_id    :integer
#  grade_id      :integer
#  scanned_image :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  examiner_id   :integer
#  contested     :boolean         default(FALSE)
#

class GradedResponse < ActiveRecord::Base
  belongs_to :quiz 
  belongs_to :question 
  belongs_to :student
  belongs_to :examiner
  belongs_to :grade

  validates :quiz_id, :presence => true
  validates :question_id, :presence => true
  validates :student_id, :presence => true

  # [:all] ~> [:admin, :cron]
  # [:grade_id] ~> [:examiner, :teacher]
  #attr_accessible
end
