# == Schema Information
#
# Table name: grade_descriptions
#
#  id                :integer         not null, primary key
#  annotation        :string(255)
#  description       :string(255)
#  default_allotment :integer
#  created_at        :datetime
#  updated_at        :datetime
#

require 'test_helper'

class GradeDescriptionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
