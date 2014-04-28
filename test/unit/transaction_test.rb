# == Schema Information
#
# Table name: transactions
#
#  id                :integer         not null, primary key
#  accounting_doc_id :integer
#  account_id        :integer
#  quantity          :integer
#  rate_code_id      :integer
#  reference_id      :integer
#  reference_type    :integer
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#

require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
