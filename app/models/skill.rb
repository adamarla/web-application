# == Schema Information
#
# Table name: skills
#
#  id         :integer         not null, primary key
#  chapter_id :integer
#  generic    :boolean         default(FALSE)
#

class Skill < ActiveRecord::Base
  has_one :sku, as: :stockable, dependent: :destroy
  before_update :set_sku_modified, if: :chapter_id_changed?
  after_create :add_sku 

  private 
    def add_sku 
      self.create_sku path: "skills/#{self.id}"
    end 

    def set_sku_modified 
      self.sku.update_attribute :modified, true 
    end 

end
