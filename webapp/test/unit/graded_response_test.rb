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
#  grade_id      :integer
#  scanned_image :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  examiner_id   :integer
#  contested     :boolean         default(FALSE)
#

require 'test_helper'

class GradedResponseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
