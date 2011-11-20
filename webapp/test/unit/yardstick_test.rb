# == Schema Information
#
# Table name: yardsticks
#
#  id                :integer         not null, primary key
#  annotation        :string(255)
#  description       :string(255)
#  default_allotment :integer
#  created_at        :datetime
#  updated_at        :datetime
#  mcq               :boolean         default(FALSE)
#  subpart           :boolean         default(FALSE)
#

require 'test_helper'

class YardstickTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
