# == Schema Information
#
# Table name: cost_codes
#
#  id           :integer         not null, primary key
#  description  :text
#  subscription :boolean
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

require 'test_helper'

class CostCodeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
