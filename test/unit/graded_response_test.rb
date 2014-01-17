# == Schema Information
#
# Table name: graded_responses
#
#  id             :integer         not null, primary key
#  student_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  examiner_id    :integer
#  q_selection_id :integer
#  marks          :float
#  scan           :string(40)
#  subpart_id     :integer
#  page           :integer
#  feedback       :integer         default(0)
#  worksheet_id   :integer
#  mobile         :boolean         default(FALSE)
#

require 'test_helper'

class GradedResponseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
