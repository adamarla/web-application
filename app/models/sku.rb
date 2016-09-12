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
  after_update :reassign_to_zips, if: :has_svgs_changed? 

  def reassign_to_zips
    return false unless self.has_svgs 

    Parcel.all.each do |parcel| 
      parcel.can_have?(self) ? parcel.add(self) : parcel.remove(self) 
    end # of each loop  
  end # of method 

  def set_modified_on_zips 
    return false unless self.has_svgs 

    zip_ids = Inventory.where(sku_id: self.id).map(&:zip_id).uniq 
    Zip.where(id: zip_ids).each do |zip|
      zip.update_attribute :modified, true
    end 
  end 

  def author_id
    parent = self.stockable 
    return parent.examiner_id
  end 

  def set_chapter_id(cid) 
    obj = self.stockable 

    if obj.instance_of? Question 
      lang = obj.language_id || Language.named('english') 
      diff = (obj.difficulty.nil? || obj.difficulty == 1) ? Difficulty.named('medium') : obj.difficulty 
      obj.update_attributes chapter_id: cid, language_id: lang, difficulty: diff 
    else 
      obj.update_attribute :chapter_id, cid 
    end 
  end 

  def set_skills(ids)
    obj = self.stockable 
    obj.set_skills(ids) unless obj.nil?
  end 

  def chapter 
    return self.stockable.chapter 
  end 

  def self.with_path(path) 
    # path = q/[ex-id]/[q-id] OR vault/[skills|snippets]/[id]
    return nil if path.blank?

    uid = (path =~ /^vault(.*)/).nil? ? path : path.split("/")[1..2].join("/")
    return Sku.where(path: uid).first 
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

  def self.in_chapter(cid)
    select{ |sku| sku.stockable.chapter_id == cid }
  end 

end # of class
