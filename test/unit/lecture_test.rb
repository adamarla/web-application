# == Schema Information
#
# Table name: lectures
#
#  id           :integer         not null, primary key
#  lesson_id    :integer
#  milestone_id :integer
#  index        :integer         default(-1)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

require 'test_helper'

class LectureTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
