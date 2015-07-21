# == Schema Information
#
# Table name: attempts
#
#  id           :integer         not null, primary key
#  pupil_id     :integer
#  question_id  :integer
#  seen_options :boolean         default(FALSE)
#  num_wrong    :integer         default(0)
#  got_right    :boolean
#  max_opened   :integer         default(0)
#  max_time     :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

require 'test_helper'

class AttemptTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
