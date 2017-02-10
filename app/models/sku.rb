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
  validates :stockable_id, uniqueness: { scope: [:stockable_type] }

  has_many :inventory, dependent: :destroy 

  def repackage
    Parcel.all.each do |parcel| 
      parcel.can_have?(self) ? parcel.add(self) : parcel.remove(self) 
    end # of each loop  
  end # of method 

  def tag_modified_zips 
    return false unless self.has_svgs 

    zip_ids = Inventory.where(sku_id: self.id).map(&:zip_id).uniq 
    Zip.where(id: zip_ids).each do |zip|
      zip.update_attribute :modified, true
    end 
  end 

  def tests_skill?(id) 
    return false if id == 0 

    obj = self.stockable
    return false unless obj.is_a?( Riddle ) 

    tested = obj.skill_list 
    return false if tested.blank?

    return Skill.where(uid: tested).map(&:id).include?(id) 
  end 

  def set_skills(ids)
    obj = self.stockable 
    obj.set_skills(ids) unless obj.nil?
  end 

  def chapter 
    return self.stockable.chapter 
  end 

  def self.with_path(path) 
    return nil if path.blank?

    # path = q/[ex-id]/[q-id] OR vault/[skills|snippets]/[id]
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
    if (cid > 0) 
      riddles = Riddle.where(chapter_id: cid) 
      skills = Skill.where(chapter_id: cid) 
    else 
      riddles = Riddle.where('id > ?', 0) 
      skills = Skill.where('id > ?', 0) 
    end 

    # This will be an Array - not an ActiveRecordRelation 
    return (Sku.where(stockable_id: riddles.map(&:id), stockable_type: "Riddle") + 
            Sku.where(stockable_id: skills.map(&:id), stockable_type: "Skill"))
  end 

end # of class
