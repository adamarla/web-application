# == Schema Information
#
# Table name: skus
#
#  id             :integer         not null, primary key
#  stockable_type :string(255)
#  stockable_id   :integer
#  path           :string(255)
#  has_svgs       :boolean         default(FALSE)
#

class Sku < ActiveRecord::Base
  belongs_to :stockable, polymorphic: true 
  validates :stockable_id, uniqueness: { scope: [:stockable_type] }

  def recompute_ownership
    return false unless self.has_svgs 

    Parcel.all.each do |parcel| 
      if parcel.can_have?(self) 
        parcel.add(self)
      else 
        parcel.remove(self)
      end 
    end # of each loop  
  end # of method 

  def set_modified_on_zips 
    return false unless self.has_svgs 

    zip_ids = Inventory.where(sku_id: self.id).map(&:zip_id).uniq 
    Zip.where(id: zip_ids).each do |zip|
      zip.update_attribute :modified, true
    end 
  end 

  def self.questions
    where(stockable_type: Question.name)
  end 

  def self.skills
    where(stockable_type: Skill.name) 
  end 

  def self.snippets
    where(stockable_type: Snippet.name) 
  end 

end
