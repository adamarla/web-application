# == Schema Information
#
# Table name: snippets
#
#  id            :integer         not null, primary key
#  examiner_id   :integer
#  skill_id      :integer
#  num_attempted :integer         default(0)
#  num_correct   :integer         default(0)
#

class Snippet < ActiveRecord::Base
  belongs_to :skill
  has_one :sku, as: :stockable, dependent: :destroy 
  after_create :add_sku 
  around_update :set_sku_ownership, if: :skill_id_changed? 

  def attempted(correctly = false) 
    correctly ? self.update_attributes(num_attempted: self.num_attempted + 1, 
                                       num_correct: self.num_correct + 1)
              : self.update_attribute(:num_attempted, self.num_attempted + 1)
  end 

  private 
    def add_sku 
      self.create_sku path: "snippets/#{self.id}"
    end 

    def set_sku_ownership
      old_skill = self.skill_id 
      yield 
      new_skill = self.skill_id 
      same_chapter = Skill.where(id: [old_skill, new_skill]).map(&:chapter_id).uniq.count == 1 
      self.sku.recompute_ownership unless same_chapter 
    end 

end
