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

# A Rate Code represents the numerical cost of product/service in a particular
# currency e.g. 
# Charge for 1 Course Credit in USD is valued at 1, or
# Charge for 1 Course Credit in INR is valued at 50, or
# Charge for 1 student-month of Assessment Service in INR is valued at 100, or 
# Charge for 1 student-month of Assessment Platform in USD is valued at 2

class RateCode < ActiveRecord::Base

  has_one :cost_code

  def self.for_course_credit(currency)
    RateCode.where(cost_code_id: 3, currency: currency).first 
  end

  def self.for_supervisory_access(currency)
    RateCode.where(cost_code_id: 6, currency: currency).first 
  end

end
