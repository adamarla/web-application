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

require 'test_helper'

class GradedResponseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
