# == Schema Information
#
# Table name: skus
#
#  id             :integer         not null, primary key
#  stockable_type :string(255)
#  stockable_id   :integer
#  path           :string(255)
#

class Sku < ActiveRecord::Base
  belongs_to :stockable, polymorphic: true 
end
