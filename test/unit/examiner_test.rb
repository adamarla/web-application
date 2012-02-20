# == Schema Information
#
# Table name: examiners
#
#  id              :integer         not null, primary key
#  num_contested   :integer         default(0)
#  created_at      :datetime
#  updated_at      :datetime
#  is_admin        :boolean         default(FALSE)
#  first_name      :string(255)
#  last_name       :string(255)
#  last_workset_on :datetime
#

require 'test_helper'

class ExaminerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
