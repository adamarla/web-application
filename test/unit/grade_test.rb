# == Schema Information
#
# Table name: grades
#
#  id             :integer         not null, primary key
#  allotment      :float
#  teacher_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  calibration_id :integer
#

require 'test_helper'

class GradeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
