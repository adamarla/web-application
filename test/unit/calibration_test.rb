# == Schema Information
#
# Table name: calibrations
#
#  id             :integer         not null, primary key
#  insight_id     :integer
#  formulation_id :integer
#  calculation_id :integer
#  mcq_id         :integer
#  allotment      :float
#  enabled        :boolean         default(TRUE)
#

require 'test_helper'

class CalibrationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
