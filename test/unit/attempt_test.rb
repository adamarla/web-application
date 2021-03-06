# == Schema Information
#
# Table name: attempts
#
#  id             :integer         not null, primary key
#  user_id        :integer
#  question_id    :integer
#  checked_answer :boolean         default(FALSE)
#  num_attempts   :integer         default(0)
#  got_right      :boolean
#  max_opened     :integer         default(0)
#  max_time       :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  total_time     :integer
#  seen_summary   :boolean         default(FALSE)
#  time_to_answer :integer
#  time_on_cards  :string(40)
#  num_surrender  :integer
#  time_to_bingo  :integer         default(0)
#

require 'test_helper'

class AttemptTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
