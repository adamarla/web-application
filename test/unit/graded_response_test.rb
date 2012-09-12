# == Schema Information
#
# Table name: graded_responses
#
#  id             :integer         not null, primary key
#  student_id     :integer
#  calibration_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#  examiner_id    :integer
#  disputed       :boolean         default(FALSE)
#  q_selection_id :integer
#  system_marks   :float
#  testpaper_id   :integer
#  scan           :string(255)
#  subpart_id     :integer
#  page           :integer
#  marks_teacher  :float
#  closed         :boolean         default(FALSE)
#

require 'test_helper'

class GradedResponseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
