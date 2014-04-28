# == Schema Information
#
# Table name: rate_codes
#
#  id           :integer         not null, primary key
#  cost_code_id :integer
#  value        :integer
#  currency     :string(3)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

require 'test_helper'

class RateCodeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
