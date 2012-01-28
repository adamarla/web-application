# == Schema Information
#
# Table name: testpapers
#
#  id         :integer         not null, primary key
#  quiz_id    :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class TestpaperTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
