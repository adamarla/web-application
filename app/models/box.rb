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
#  of_questions   :boolean         default(FALSE)
#  of_skills      :boolean         default(FALSE)
#  of_snippets    :boolean         default(FALSE)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

class Box < ActiveRecord::Base
  validates :name, uniqueness: true 
  validates :chapter_id, numericality: { only_integer: true, greater_than: 0 }
  validates :chapter_id, uniqueness: { scope: [:language_id, :min_difficulty, :max_difficulty] }, if: :of_questions
  validates :chapter_id, uniqueness: { scope: [:of_snippets, :of_skills] }, unless: :of_questions

  belongs_to :chapter 
  belongs_to :language 

  after_create :seal 

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


  def self.for_chapter(chapter, language = Language.named('english'))
    # There can be multiple box of questions for the same chapter. 
    # The difference could be in target language, difficulty levels etc. 
    # But there can be *only one* box of skills and snippets. 
    
    # This method creates a box for questions - and any for snippets
    # and skills.

    b = Box.create(chapter_id: chapter, language_id: language, of_questions: true)
    b.set_difficulty_range Difficulty.named('easy'), Difficulty.named('medium')
  end 

  private 
    def seal 
      hex_time = Time.now.to_i.to_s(16)
      prefix = self.of_questions ? "q" : (self.of_skills ? "sk" : "sn")
      self.update_attribute :name, "#{prefix}-#{hex_time}"

      return unless self.of_questions
      Box.create(chapter_id: self.chapter_id, of_skills: true) 
      Box.create(chapter_id: self.chapter_id, of_snippets: true) 

    end 

end
