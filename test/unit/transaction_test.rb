# == Schema Information
#
# Table name: transactions
#
#  id             :integer         not null, primary key
#  account_id     :integer
#  quantity       :integer
#  rate_code_id   :integer
#  reference_id   :integer
#  reference_type :string(20)
#  memo           :string(255)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
