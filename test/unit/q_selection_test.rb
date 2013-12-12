# == Schema Information
#
# Table name: q_selections
#
#  id          :integer         not null, primary key
#  quiz_id     :integer
#  question_id :integer
#  start_page  :integer
#  created_at  :datetime
#  updated_at  :datetime
#  index       :integer
#  end_page    :integer
#  shadow      :integer
#  page_breaks :string(10)
#

require 'test_helper'

class QSelectionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
