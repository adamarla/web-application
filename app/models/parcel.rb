# == Schema Information
#
# Table name: parcels
#
#  id             :integer         not null, primary key
#  name           :string(50)
#  chapter_id     :integer
#  language_id    :integer         default(1)
#  min_difficulty :integer
#  max_difficulty :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  contains       :string(20)
#  max_zip_size   :integer
#  skill_id       :integer         default(0)
#  open           :boolean         default(TRUE)
#

class Parcel < ActiveRecord::Base

=begin

  -----------------------------------------------------------------
   Parcel Type        Unique by 
  -----------------------------------------------------------------
    Any               (name) 
    Skill             (language, chapter) 
    Snippet           (language, chapter, skill)
    Question          (language, chapter, skill, difficulty range)
  -----------------------------------------------------------------

=end 
  validates :name, uniqueness: true 
  validates :chapter_id, numericality: { only_integer: true, greater_than: 0 }
  validates :language_id, uniqueness: { scope: [:chapter_id] }, if: :for_skills? 

  validates :skill_id, uniqueness: { scope: [ :contains, 
                                              :chapter_id, 
                                              :language_id ] }, if: :for_snippets? 

  validates :skill_id, uniqueness: { scope: [ :contains, 
                                              :chapter_id, 
                                              :language_id, 
                                              :min_difficulty, 
                                              :max_difficulty ] }, if: :for_questions? 

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

  def for_snippets? 
    return self.contains == Snippet.name 
  end 

  def skill_specific?
    return self.skill_id > 0 
  end 

  def can_have?(obj) 
    return false unless (obj.has_svgs && self.open)

    # At the very least, language and chapter must match
    return false if obj.chapter_id != self.chapter_id 
    return false if (!self.language_id.blank? && (self.language_id != obj.language_id)) # nil => english 

    # No more checks for Skills 
    return true if obj.is_a?(Skill)

    # Does this parcel accept only SKUs w/ specific skills 
    return false if (self.skill_id > 0 && !obj.tests_skill?(self.skill_id))

    # No more checks for Snippets 
    return true if obj.is_a?(Snippet)

    # => Question. Check for difficulty range 
    return (obj.difficulty >= self.min_difficulty && obj.difficulty <= self.max_difficulty)
  end 

  def zip_that_has(sku)
    self.zips.each do |z|
      return z if z.has?(sku)
    end 
    return nil 
  end 

  def add(sku)
    # Method assumes this parcel can_have? passed SKU 

    return false unless self.zip_that_has(sku).nil? # if already added 
    open_zip = Zip.where(parcel_id: self.id, open: true).last || self.zips.create 
    open_zip.skus << sku 
    # puts " ------- Adding #{sku.id} to #{open_zip.id}"
  end 

  def remove(sku)
    # Method assumes that passed SKU has been ascertained to be removed 

    zip = self.zip_that_has(sku) 
    return false if zip.nil? # false alarm. Not in this parcel
    zip.sku_ids = zip.sku_ids - [sku.id]
    # puts " ------- Removing #{sku.id} from #{zip.id}"
  end 

  def modified?
    # Modified if some zip within has changed 
    zips = Zip.where(parcel_id: self.id, modified: true) 
    return (zips.count > 0)
  end 

  def next_zip(ids) 
    return self.zips.first if self.contains == "Skill" 

    # We want to return the *next* zip that a user must download 
    # given the Riddles already attempted  

    rd = Riddle.where('id IN (?) OR original_id IN (?)', ids, ids).map(&:id)
    sku_d = Sku.where(stockable_id: rd).map(&:id) 
    in_parcel = Inventory.where(zip_id: self.zip_ids)
    tbd = in_parcel.where(sku_id: in_parcel.map(&:sku_id) - sku_d)

    # Look for the zip with most un-attempted matches 
    zips = tbd.map(&:zip_id) 
    good_fits, bad_fits = zips.partition{ |z| zips.count(z) >= 6 }

    # Randomly return one of the good-fits else one of the bad-fits 
    zid = good_fits.blank? ? bad_fits.uniq.sample(1).first : good_fits.uniq.sample(1).first 
    return (zid.blank? ? nil : Zip.find(zid))
  end 

  def to_json
    ret = { id: self.id, type: self.contains, name: self.name, chapter_id: self.chapter_id } 

    unless self.contains == "Skill"
      ret[:skill] = self.skill_id 

      if self.contains == "Question" 
        ret[:min] = self.min_difficulty 
        ret[:max] = self.max_difficulty
      end 
    end 
    return ret 
  end 

  private 

    def seal 
      query = { has_svgs: true, chapter_id: self.chapter_id }

      case self.contains 
        when Question.name
          suffix = self.skill_id > 0 ? "SK#{self.skill_id}Q#{self.id}" : "Q#{self.id}"
          max_size = 10 
          list = Question.where(query)
        when Skill.name 
          suffix = "SK#{self.id}" 
          max_size = -1
          list = Skill.where(query)
        else 
          suffix = self.skill_id > 0 ? "SK#{self.skill_id}SN#{self.id}" : "SN#{self.id}"
          max_size = 20 
          list = Snippet.where(query)
      end 

      self.update_attributes name: "C#{self.chapter_id}#{suffix}", max_zip_size: max_size 

      # This is a new Parcel. Fill it with relevant SKUs
      list.each do |obj| 
        self.add(obj.sku) if self.can_have?(obj)
      end 
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
