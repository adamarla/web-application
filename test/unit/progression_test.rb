# == Schema Information
#
# Table name: progressions
#
#  id           :integer         not null, primary key
#  student_id   :integer
#  milestone_id :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

require 'test_helper'

class ProgressionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
