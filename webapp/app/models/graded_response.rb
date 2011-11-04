# == Schema Information
#
# Table name: graded_responses
#
#  id            :integer         not null, primary key
#  quiz_id       :integer
#  question_id   :integer
#  student_id    :integer
#  index_in_quiz :integer
#  on_page       :integer
#  grade         :integer
#  scanned_image :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class GradedResponse < ActiveRecord::Base
  belongs_to :quiz 
  belongs_to :question 
  belongs_to :student
end
