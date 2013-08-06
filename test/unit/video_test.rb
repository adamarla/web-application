# == Schema Information
#
# Table name: videos
#
#  id         :integer         not null, primary key
#  url        :text
#  tutorial   :boolean         default(TRUE)
#  created_at :datetime
#  updated_at :datetime
#  title      :string(70)
#  active     :boolean         default(FALSE)
#  index      :integer         default(-1)
#  history    :boolean         default(FALSE)
#  lecture    :boolean         default(FALSE)
#

require 'test_helper'

class VideoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

