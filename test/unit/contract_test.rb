# == Schema Information
#
# Table name: contracts
#
#  id                :integer         not null, primary key
#  customer_id       :integer
#  start_date        :date
#  duration          :integer
#  bill_cycle        :integer
#  bill_day_of_month :integer
#  rate_code_id      :integer
#  num_students      :integer
#  subject_id        :integer
#  title             :string(30)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#

require 'test_helper'

class ContractTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
