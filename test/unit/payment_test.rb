# == Schema Information
#
# Table name: payments
#
#  id               :integer         not null, primary key
#  invoice_id       :integer
#  ip_address       :string(16)
#  name             :string(60)
#  source           :string(30)
#  cash_value       :integer
#  currency         :string(3)
#  credits          :integer
#  success          :boolean
#  response_message :string(255)
#  response_params  :text
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
