# == Schema Information
#
# Table name: payments
#
#  id               :integer         not null, primary key
#  transaction_id   :integer
#  ip_address       :string(16)
#  first_name       :string(30)
#  last_name        :string(30)
#  payment_type     :string(30)
#  cash_value       :integer
#  currency         :string(255)
#  credits          :integer
#  success          :boolean
#  response_message :string(255)
#  response_params  :string(255)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
