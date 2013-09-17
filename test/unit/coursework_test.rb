# == Schema Information
#
# Table name: coursework
#
#  id           :integer         not null, primary key
#  milestone_id :integer
#  quiz_id      :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

require 'test_helper'

class CourseworkTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
