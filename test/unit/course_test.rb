# == Schema Information
#
# Table name: courses
#
#  id         :integer         not null, primary key
#  name       :string(50)
#  teacher_id :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
