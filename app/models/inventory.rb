# == Schema Information
#
# Table name: inventory
#
#  id     :integer         not null, primary key
#  zip_id :integer
#  sku_id :integer
#

class Inventory < ActiveRecord::Base
  belongs_to :zip 
  belongs_to :sku
end
