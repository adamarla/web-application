# == Schema Information
#
# Table name: testpapers
#
#  id          :integer         not null, primary key
#  quiz_id     :integer
#  name        :string(100)
#  created_at  :datetime
#  updated_at  :datetime
#  publishable :boolean         default(FALSE)
#  exclusive   :boolean         default(TRUE)
#

require 'test_helper'

class TestpaperTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
