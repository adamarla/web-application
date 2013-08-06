# == Schema Information
#
# Table name: concepts
#
#  id         :integer         not null, primary key
#  name       :string(70)
#  index      :integer         default(-1)
#  course_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class ConceptTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
