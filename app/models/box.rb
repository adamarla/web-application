# == Schema Information
#
# Table name: boxes
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
#

class Box < ActiveRecord::Base
  validates :name, uniqueness: true 
  validates :chapter_id, numericality: { only_integer: true, greater_than: 0 }
  validates :chapter_id, uniqueness: { scope: [:language_id, :min_difficulty, :max_difficulty] }, if: :for_questions?
  validates :chapter_id, uniqueness: { scope: [:contains] }, unless: :for_questions?

  belongs_to :chapter 
  belongs_to :language 

  after_create :seal 

  def for_questions?
    return self.contains == Question.name 
  end 

  def for_skills? 
    return self.contains == Skill.name 
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

  def can_accept?(obj) 
    return false unless (self.contains == obj.class.name)
    # obj can only be Question, Snippet or Skill now 

    case obj 
      when Question 
        return false if (obj.chapter_id != self.chapter_id || obj.language_id != self.language_id)
        return false if (obj.difficulty < self.min_difficulty || obj.difficulty > self.max_difficulty)
      when Skill 
        return (obj.chapter_id == self.chapter_id)
      when Snippet 
        return (obj.skill.chapter_id == self.chapter_id)
    end 

    return true 
  end 


  def self.for_chapter(chapter, language = Language.named('english'))
    # There can be multiple box of questions for the same chapter. 
    # The difference could be in target language, difficulty levels etc. 
    # But there can be *only one* box of skills and snippets. 
    
    # This method creates a box for questions - and any for snippets
    # and skills.

    b = Box.create(chapter_id: chapter, language_id: language, contains: Question.name) 
    b.set_difficulty_range Difficulty.named('easy'), Difficulty.named('medium')
  end 

  private 
    def seal 
      hex_time = Time.now.to_i.to_s(16)
      prefix = self.for_questions? ? "q" : (self.for_skills? ? "sk" : "sn")
      self.update_attribute :name, "#{prefix}-#{hex_time}"

      return unless self.for_questions?
      Box.create(chapter_id: self.chapter_id, contains: Skill.name) 
      Box.create(chapter_id: self.chapter_id, contains: Snippet.name)

    end 

end
