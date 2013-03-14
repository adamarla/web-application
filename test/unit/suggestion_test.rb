# == Schema Information
#
# Table name: suggestions
#
#  id          :integer         not null, primary key
#  teacher_id  :integer
#  examiner_id :integer
#  completed   :boolean         default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#  signature   :string(15)
#  pages       :integer         default(1)
#

require 'test_helper'

class SuggestionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
