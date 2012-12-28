# == Schema Information
#
# Table name: topics
#
#  id          :integer         not null, primary key
#  name        :string(50)
#  created_at  :datetime
#  updated_at  :datetime
#  vertical_id :integer
#

require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
