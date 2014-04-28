# == Schema Information
#
# Table name: customers
#
#  id             :integer         not null, primary key
#  account_id     :integer
#  credit_balance :integer         default(0)
#  cash_balance   :integer         default(0)
#  currency       :string(3)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
