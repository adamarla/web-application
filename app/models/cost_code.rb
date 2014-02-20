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

# A Cost Code represents a single unit of product/service being purchased 
# e.g. Assessment Platform for 1 student-month or 
#      Assessment Service for 1 student-month or
#      Supervised course work worth 1 credit (grade-it)

class CostCode < ActiveRecord::Base

end
