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

class CostCode < ActiveRecord::Base
  attr_accessible :description, :subscription
end
