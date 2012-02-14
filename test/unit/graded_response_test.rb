# == Schema Information
#
# Table name: graded_responses
#
#  id             :integer         not null, primary key
#  student_id     :integer
#  grade_id       :integer
#  created_at     :datetime
#  updated_at     :datetime
#  examiner_id    :integer
#  contested      :boolean         default(FALSE)
#  q_selection_id :integer
#  marks          :float
#  testpaper_id   :integer
#  scan           :string(255)
#

require 'test_helper'

class GradedResponseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
