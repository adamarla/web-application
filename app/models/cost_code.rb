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

# A Cost Code represents the nature of product/service being purchased 
# e.g. Assessment Platform (Service) or Course Credit for purchasing 
# courses (Product) etc.

class CostCode < ActiveRecord::Base

end
