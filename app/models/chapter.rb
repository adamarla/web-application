# == Schema Information
#
# Table name: chapters
#
#  id          :integer         not null, primary key
#  name        :string(70)
#  level_id    :integer
#  subject_id  :integer
#  uid         :string(10)
#  language_id :integer         default(1)
#  parent_id   :integer         default(0)
#  friend_id   :integer         default(0)
#

# Parent - always in English 
# Friend - always in the same language as the chapter 

# Assumption: Chapters are first created for English and then duplicated 

class Chapter < ActiveRecord::Base
  belongs_to :level 
  belongs_to :subject 

  validates :name, presence: true 
  validates :name, uniqueness: { scope: [:level_id, :subject_id, :language_id] }
  validates :parent_id, numericality: { equal_to: 0 }, if: :in_english?

  before_validation :titleize, if: :name_changed? 

  after_create :seal 

  def parcels
    # If a Chapter has a friend, then we include the skills 
    # in the friend too. But a friend's friend is not necessarily
    # your friend. Hence, this method is *not* recursive

    Parcel.where('chapter_id = ? OR (chapter_id = ? AND contains = ?)', self.id, self.friend_id, "Skill")
  end 

  def skills 
    Skill.where('chapter_id = ? OR chapter_id = ?', self.id, self.friend_id)
  end 

  def inventory
    Parcel.where(chapter_id: self.id).each do |p| 
      num_skus = p.zips.map(&:sku_ids).flatten.count 
      # puts "# #{p.contains} = #{num_skus}"
    end 
  end 

  def titleize 
    return if self.name.blank? 

    tokens = self.name.downcase.split(" ")
    conjunctions = ["a","an","and","the","of","on","in"] 

    tokens.each_with_index do |t,j| 
      tokens[j] = conjunctions.include?(t) ? t.downcase : t.titleize
    end 
    self.name = tokens.join(" ")
  end 

  # To be used when we start supporting multiple languages. 
  # No immediate use as of Feb 2017

  def duplicate(name, language) 
    # English is our base language for everything!
    return nil if (self.language_id != Language.named('english') || language == self.language_id)

    # Use to create Chapter entity in a different language 
    friend = self.friend_id > 0 ? Chapter.find(self.friend_id) : nil 

    unless friend.nil? 
      pal = Chapter.where(parent_id: friend.id, language_id: language).first || 
              friend.duplicate(friend.name, language) 
    else
      pal = nil 
    end 

    Chapter.create name: name, 
                   language_id: language, 
                   level_id: self.level_id, 
                   subject_id: self.subject_id, 
                   parent_id: self.id,
                   friend_id: (pal.nil? ? 0 : pal.id)
  end 

  def self.quick_add(name) 
    Chapter.create name: name, level_id: Level.named('senior'), subject_id: Subject.named('maths') 
  end 

  def self.generic
    return where(name: "generic".titleize).first
  end 

  private 

      def seal 
        # Remove conjunctions from name 
        x = self.name.downcase.gsub /\s+(a|an|and|the|of|in|on)\s+/, ' '  
        code = x.split(' ')[0..1].map{ |tkn| tkn[0..3] }.join.upcase
        self.update_attribute :uid, code

        # Create a Parcel for Skills. Those for Riddles will be auto-created 
        # when a Riddle is packaged 

        Parcel.create chapter_id: self.chapter_id, 
                      contains: Skill.name, 
                      language_id: self.language_id 

        # TBD: And then translations of the parent's skills 
        return if self.parent_id == 0 
      end 

      def in_english?
        return self.language_id == Language.named('english')
      end 
end
