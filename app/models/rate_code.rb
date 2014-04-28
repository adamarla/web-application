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
# Per Course Credit in USD valued at 1
# Per Course Credit in INR valued at 50
# Per student-month of Assessment Service in INR is valued at 100 
# Per student-month of Assessment Platform in USD is valued at 2
# Per student for Assessment Service demo in INR valued at 100
# One time INR payment for Assessment Platform demo valued at 10,000

class RateCode < ActiveRecord::Base

  def self.for_course_credit(currency)
    RateCode.where(cost_code_id: CC_COURSE_CREDIT, currency: currency).first 
  end

  def self.for_supervisory_access(currency)
    RateCode.where(cost_code_id: CC_SUPERVISORY_ACCESS, currency: currency).first 
  end

end
