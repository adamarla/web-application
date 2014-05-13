# == Schema Information
#
# Table name: accounting_docs
#
#  id          :integer         not null, primary key
#  doc_type    :integer
#  customer_id :integer
#  doc_date    :date
#  open        :boolean         default(TRUE)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

require 'test_helper'

class AccountingDocTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
