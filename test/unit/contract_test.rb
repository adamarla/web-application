# == Schema Information
#
# Table name: contracts
#
#  id                 :integer         not null, primary key
#  school_id          :integer
#  start_date         :date
#  duration           :integer
#  bill_cycle         :integer
#  start_day_of_month :integer
#  rate_code_id       :integer
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  grade_level        :integer
#  num_students       :integer
#  subject_id         :integer
#

require 'test_helper'

class ContractTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
