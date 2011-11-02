# == Schema Information
#
# Table name: syllabi
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  board_id   :integer
#  grade      :integer
#  subject    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class SyllabusTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
