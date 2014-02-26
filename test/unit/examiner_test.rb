# == Schema Information
#
# Table name: examiners
#
#  id                :integer         not null, primary key
#  created_at        :datetime
#  updated_at        :datetime
#  is_admin          :boolean         default(FALSE)
#  first_name        :string(30)
#  last_name         :string(30)
#  last_workset_on   :datetime
#  n_assigned        :integer         default(0)
#  n_graded          :integer         default(0)
#  live              :boolean         default(FALSE)
#  mentor_id         :integer
#  mentor_is_teacher :boolean         default(FALSE)
#  internal          :boolean         default(FALSE)
#

require 'test_helper'

class ExaminerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
