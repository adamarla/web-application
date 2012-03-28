# == Schema Information
#
# Table name: course_packs
#
#  id           :integer         not null, primary key
#  student_id   :integer
#  testpaper_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#  marks        :float
#  graded       :boolean         default(FALSE)
#

require 'test_helper'

class CoursePackTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
