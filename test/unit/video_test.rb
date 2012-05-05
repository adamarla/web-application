# == Schema Information
#
# Table name: videos
#
#  id            :integer         not null, primary key
#  url           :string(255)
#  restricted    :boolean         default(TRUE)
#  instructional :boolean         default(FALSE)
#  created_at    :datetime
#  updated_at    :datetime
#

require 'test_helper'

class VideoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
