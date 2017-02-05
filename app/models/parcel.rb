# == Schema Information
#
# Table name: parcels
#
#  id             :integer         not null, primary key
#  name           :string(15)
#  chapter_id     :integer
#  language_id    :integer
#  min_difficulty :integer
#  max_difficulty :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  contains       :string(20)
#  max_zip_size   :integer         default(-1)
#  skill_id       :integer         default(0)
#

class Parcel < ActiveRecord::Base
  validates :name, uniqueness: true 
  validates :chapter_id, numericality: { only_integer: true, greater_than: 0 }
  validates :chapter_id, uniqueness: { scope: [:language_id, :min_difficulty, :max_difficulty] }, if: :for_questions?
  validates :chapter_id, uniqueness: { scope: [:contains] }, unless: :for_questions?

  belongs_to :chapter 
  belongs_to :language 
  has_many :zips, dependent: :destroy 

  after_create :seal 
  after_update :reset_zip_sizes, if: :max_zip_size_changed? 

  def for_questions?
    return self.contains == Question.name 
  end 

  def for_skills? 
    return self.contains == Skill.name 
  end 

  def skill_specific?
    return self.skill_id > 0 
  end 

  def set_difficulty_range(min, max) 
    return if (min == 0 || max == 0) 
    if (min > max) 
      tmp = min 
      min = max 
      max = tmp 
    end 

    # Set the difficulties
    self.update_attributes min_difficulty: min, max_difficulty: max
  end 

  def can_have?(sku) 
    # Is the SKU of the right type to go into this Parcel? 
    return false unless (self.contains == sku.stockable_type)

    # Does the SKU match the conditions set on the Parcel?
    # obj can only be Question, Snippet or Skill now 

    obj = sku.stockable

    case obj 
      when Question 
        return false if (obj.chapter_id != self.chapter_id || obj.language_id != self.language_id)
        return false if (obj.difficulty < self.min_difficulty || obj.difficulty > self.max_difficulty)
      when Snippet, Skill 
        return (obj.chapter_id == self.chapter_id)
    end 
    return true 
  end 

  def parent_zip(sku)
    self.zips.each do |z|
      return z if z.has?(sku)
    end 
    return nil 
  end 

  def add(sku)
    # Method assumes this parcel can_have? passed SKU 

    return false unless self.parent_zip(sku).nil? # if already added 
    open_zip = Zip.where(parcel_id: self.id, open: true).last || self.zips.create 
    open_zip.skus << sku 
  end 

  def remove(sku)
    # Method assumes that passed SKU has been ascertained to be removed 

    zip = self.parent_zip(sku) 
    return false if zip.nil? # false alarm. Not in this parcel
    zip.sku_ids = zip.sku_ids - [sku.id]
  end 

  def modified?
    # Modified if some zip within has changed 
    zips = Zip.where(parcel_id: self.id, modified: true) 
    return (zips.count > 0)
  end 

  def next_zip(ids) 
    # We want to return the *next* zip that a user must download 
    # given the SKUs that he has already attempted 

    entries = Inventory.where(zip_id: self.zip_ids)
    attempted_sku_ids = Sku.where(stockable_id: ids, stockable_type: self.contains).map(&:id)
    unattempted = entries.where(sku_id: (entries.map(&:sku_id) - attempted_sku_ids))

    zips = unattempted.map(&:zip_id)
    cnd, others = zips.partition{ |z| zips.count(z) >= 6 }

    # Randomly return one of the eligible zips (>= 6 unattempted SKUs). 
    # And if no eligible zip, then return one of the others. 

    ret_id = (cnd.blank? ? others.uniq.sample(1).first : cnd.uniq.sample(1).first)
    return (ret_id.blank? ? nil : Zip.find(ret_id))
  end 

  def to_json 
    ret = { id: self.id, type: self.contains, name: self.name } 
    if self.contains == Question.name 
      ret[:min] = self.min_difficulty 
      ret[:max] = self.max_difficulty
    end 
    return ret 
  end 

  def self.for_chapter(cid, language = Language.named('english'))
    # There can be multiple parcel of questions for the same chapter. 
    # The difference could be in target language, difficulty levels etc. 
    # But there can be *only one* parcel of skills and snippets. 
    
    # This method creates a parcel for questions - and any for snippets
    # and skills.

    p = Parcel.create(chapter_id: cid, language_id: language, contains: Question.name) 
    p.set_difficulty_range Difficulty.named('easy'), Difficulty.named('medium')
  end 

  private 

    def seal 
      case self.contains 
        when Question.name
          suffix = "Q#{self.id}"
          max_size = 10 
        when Skill.name 
          suffix = "SK#{self.id}" 
          max_size = -1
        else 
          suffix = "SN#{self.id}"
          max_size = 20 
      end 

      self.update_attributes name: "C#{self.chapter_id}#{suffix}", max_zip_size: max_size 

      # This is a new Parcel. Fill it with any relevant SKUs  
      Sku.where(has_svgs: true).each do |sku| 
        self.add(sku) if self.can_have?(sku)
      end 

      return unless self.for_questions?
      Parcel.create(chapter_id: self.chapter_id, contains: Skill.name) 
      Parcel.create(chapter_id: self.chapter_id, contains: Snippet.name)
    end 

    def reset_zip_sizes
      # Zips that were closed will stay closed. 
      # A zip can only go from open -> closed here. 

      open_zips = Zip.where(parcel_id: self.id, open: true) # there should be only one!
      open_zips.each do |z| 
        z.update_attribute :max_size, self.max_zip_size
      end 
    end 

end
