# == Schema Information
#
# Table name: skills
#
#  id         :integer         not null, primary key
#  chapter_id :integer
#  generic    :boolean         default(FALSE)
#  uid        :string(15)
#

class Skill < ActiveRecord::Base
  belongs_to :chapter 
  has_one :sku, as: :stockable, dependent: :destroy

  around_update :set_sku_ownership, if: :chapter_id_changed?
  after_create :add_sku, :set_uid 

  private 
    def add_sku 
      self.create_sku path: "skills/#{self.id}"
    end 

    def set_uid 
      self.update_attribute :uid, "#{self.chapter.uid}-#{self.id}"    
    end 

    def set_sku_ownership 
      yield
      self.sku.edit_zips
    end 

end
