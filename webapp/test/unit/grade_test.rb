# == Schema Information
#
# Table name: grades
#
#  id                   :integer         not null, primary key
#  allotment            :integer
#  grade_description_id :integer
#  teacher_id           :integer
#  created_at           :datetime
#  updated_at           :datetime
#

require 'test_helper'

class GradeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
