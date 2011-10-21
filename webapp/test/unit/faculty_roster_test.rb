# == Schema Information
#
# Table name: faculty_rosters
#
#  id             :integer         not null, primary key
#  study_group_id :integer
#  teacher_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#

require 'test_helper'

class FacultyRosterTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
