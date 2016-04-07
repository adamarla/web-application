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

  after_create :seal
  around_update :set_sku_ownership, if: :chapter_id_changed?

  private 
    def seal 
      self.create_sku path: "skills/#{self.id}"
      self.update_attributes uid: "#{self.chapter.uid}-#{self.id}", generic: (self.chapter_id == Chapter.generic.id)
    end 

    def set_sku_ownership 
      self.generic = self.chapter_id == Chapter.generic.id 
      yield 
      self.sku.edit_zips
    end 

end
