# == Schema Information
#
# Table name: videos
#
#  id            :integer         not null, primary key
#  url           :text
#  restricted    :boolean         default(TRUE)
#  instructional :boolean         default(FALSE)
#  created_at    :datetime
#  updated_at    :datetime
#  title         :string(255)
#  active        :boolean         default(FALSE)
#  index         :integer         default(-1)
#

require 'test_helper'

class VideoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
