# == Schema Information
#
# Table name: attempts 
#
#  id             :integer         not null, primary key
#  student_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  examiner_id    :integer
#  q_selection_id :integer
#  marks          :float
#  scan           :string(40)
#  subpart_id     :integer
#  page           :integer
#  feedback       :integer         default(0)
#  worksheet_id   :integer
#  mobile         :boolean         default(FALSE)
#  disputed       :boolean         default(FALSE)
#  resolved       :boolean         default(FALSE)
#  orange_flag    :boolean
#  red_flag       :boolean
#  weak           :boolean
#  medium         :boolean
#  strong         :boolean
#

require 'test_helper'

class AttemptTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
