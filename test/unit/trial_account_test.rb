# == Schema Information
#
# Table name: trial_accounts
#
#  id         :integer         not null, primary key
#  teacher_id :integer
#  school     :string(255)
#  zip_code   :string(30)
#  country    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class TrialAccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
