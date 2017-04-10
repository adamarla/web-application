# == Schema Information
#
# Table name: examiners
#
#  id         :integer         not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  is_admin   :boolean         default(FALSE)
#  first_name :string(30)
#  last_name  :string(30)
#  live       :boolean         default(FALSE)
#

require 'test_helper'

class ExaminerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
