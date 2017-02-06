# == Schema Information
#
# Table name: snippets
#
#  id            :integer         not null, primary key
#  examiner_id   :integer
#  num_attempted :integer         default(0)
#  num_correct   :integer         default(0)
#  chapter_id    :integer
#  language_id   :integer         default(1)
#

class Snippet < ActiveRecord::Base
  belongs_to :chapter
  has_one :sku, as: :stockable, dependent: :destroy 

  after_create :add_sku 
  around_update :reassign_to_zips, if: :chapter_id_changed?

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
    # Only consider Snippets that belong to the same Chapters 
    # as the passed Skills

    cids = Skill.where(id: skill_ids).map(&:chapter_id).uniq 
    skills = Skill.where(id: skill_ids).map(&:uid)
    return Snippet.where(chapter_id: cids).tagged_with(skills, any: true, on: :skills)
  end 

  private 
    def add_sku 
      self.create_sku path: "snippets/#{self.id}"
    end 

    def reassign_to_zips
      # old_skill = self.skill_id 

      yield 
      self.sku.reassign_to_zips 

      # new_skill = self.skill_id 
      # same_chapter = Skill.where(id: [old_skill, new_skill]).map(&:chapter_id).uniq.count == 1 
      # self.sku.reassign_to_zips unless same_chapter 
    end 

end
