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

# A Rate Code represents the numerical cost of product in a particular
# currency e.g. 1 Course Credit is valued at 1 USD,
# or 1 Course Credit is valued at 50 INR etc. Each of these would
# be a Rate Code.

# In case of Services, like Assessment Service for schools, when a
# Contract is created, the periodic billing rate per student per
# period in a particular currency is represented by a Rate Code 
# e.g. A school in India could purchase Grading Service for 100 INR per 
# student per month or,
# an institution in the US could purchase the Assessment Platform for 2 USD
# per student per month.
# Each contract could result in a new Rate Code.

class RateCode < ActiveRecord::Base

  has_one :cost_code


end
