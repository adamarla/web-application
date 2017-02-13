# == Schema Information
#
# Table name: fragments
#
#  id            :integer         not null, primary key
#  chapter_id    :integer
#  language_id   :integer         default(1)
#  examiner_id   :integer
#  num_attempted :integer         default(0)
#  num_correct   :integer         default(0)
#

class Fragment < ActiveRecord::Base
  belongs_to :chapter
  has_one :sku, as: :stockable, dependent: :destroy 

  after_create :add_sku 
  around_update :repackage, if: :retagged?
  before_destroy :duplicate 

  acts_as_taggable_on :skills 

  def set_skills(skill_ids) 
    return false if skill_ids.blank?
    uids = Skill.where(id: skill_ids).map(&:uid).join(',')
    self.skill_list = uids 
    self.save 
  end 

  def attempted(correctly = false) 
    correctly ? self.update_attributes(num_attempted: self.num_attempted + 1, 
                                       num_correct: self.num_correct + 1)
              : self.update_attribute(:num_attempted, self.num_attempted + 1)
  end 

  def self.with_skills(skill_ids)
    # Only consider Fragments that belong to the same Chapters 
    # as the passed Skills

    cids = Skill.where(id: skill_ids).map(&:chapter_id).uniq 
    skills = Skill.where(id: skill_ids).map(&:uid)
    return Fragment.where(chapter_id: cids).tagged_with(skills, any: true, on: :skills)
  end 

  private 
    def add_sku 
      self.create_sku path: "snippets/#{self.id}"
    end 

    def retagged? 
      return (self.chapter_id_changed? || 
              self.language_id_changed?)
    end 

    def repackage

      yield 
      self.sku.repackage 

    end 

    def duplicate 
      english = Language.named 'english' 
      medium = Difficulty.named 'medium' 

      snpt = Snippet.create original_id: self.id, 
                         chapter_id: self.chapter_id, 
                         language_id: self.language_id || english, 
                         difficulty: medium,
                         examiner_id: self.examiner_id,
                         num_attempted: self.num_attempted,
                         num_completed: self.num_attempted,
                         num_correct: self.num_correct
 
      # Transfer skills to Question 
      snpt.set_skills(Skill.where(uid: self.skill_list).map(&:id))

      # Remove skills now that object is going to be destroyed 
      self.skill_list = [] 
      self.save
    end 

end # of class 
