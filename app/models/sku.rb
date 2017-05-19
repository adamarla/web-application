# == Schema Information
#
# Table name: skus
#
#  id             :integer         not null, primary key
#  stockable_type :string(255)
#  stockable_id   :integer
#  path           :string(255)
#  has_draft      :boolean         default(FALSE)
#  num_eps        :integer         default(0)
#

class Sku < ActiveRecord::Base
  belongs_to :stockable, polymorphic: true 
  validates :stockable_id, uniqueness: { scope: [:stockable_type] }

  has_many :inventory, dependent: :destroy 

  def tag_modified_zips 
    return false unless self.stockable.has_svgs 

    zip_ids = Inventory.where(sku_id: self.id).map(&:zip_id).uniq 
    Zip.where(id: zip_ids).each do |zip|
      zip.update_attribute :modified, true
    end 
  end 

  def chapter 
    return self.stockable.chapter 
  end 

  def decompile 
    parent = self.stockable 
    return { 
      id: self.id, 
      db_id: self.stockable_id,  
      type: parent.is_a?(Question) ? 1 : (parent.is_a?(Snippet) ? 2 : 4),
      chapter: parent.chapter_id, 
      author: parent.author_id, 
      has_tex: parent.has_svgs,
      path: self.path, 
      has_draft: self.has_draft,
      num_eps: self.num_eps } 
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
