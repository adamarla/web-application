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
#  sublime_uid    :string(20)
#  sublime_title  :string(70)
#

require 'test_helper'

class VideoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

