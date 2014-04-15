# == Schema Information
#
# Table name: teachers
#
#  id         :integer         not null, primary key
#  first_name :string(30)
#  last_name  :string(30)
#  created_at :datetime
#  updated_at :datetime
#  school_id  :integer
#  indie      :boolean         default(TRUE)
#

require 'test_helper'

class TeacherTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
