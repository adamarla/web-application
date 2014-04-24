# == Schema Information
#
# Table name: videos
#
#  id             :integer         not null, primary key
#  created_at     :datetime
#  updated_at     :datetime
#  active         :boolean         default(FALSE)
#  watchable_id   :integer
#  watchable_type :string(20)
#  uid            :string(20)
#

require 'test_helper'

class VideoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

