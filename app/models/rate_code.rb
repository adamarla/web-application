# == Schema Information
#
# Table name: rate_codes
#
#  id           :integer         not null, primary key
#  cost_code_id :integer
#  value        :integer
#  currency     :string(3)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class RateCode < ActiveRecord::Base
  attr_accessible :cost_code_id, :currency, :value

  has_one :cost_code
end
