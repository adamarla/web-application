# == Schema Information
#
# Table name: skills
#
#  id              :integer         not null, primary key
#  chapter_id      :integer
#  generic         :boolean         default(FALSE)
#  uid             :string(15)
#  examiner_id     :integer
#  avg_proficiency :float           default(0.0)
#

class Skill < ActiveRecord::Base
  belongs_to :chapter 
  has_one :sku, as: :stockable, dependent: :destroy

  after_create :seal
  around_update :set_sku_ownership, if: :chapter_id_changed?

  validates :avg_proficiency, on: :update, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def revaluate_proficiency
    e = Expertise.where(skill_id: self.id) 
    return if e.blank?

    wt_tested = e.map(&:weighted_tested).inject(:+)
    return if wt_tested == 0 

    wt_correct = e.map(&:weighted_correct).inject(:+)
    score = (wt_correct / wt_tested) * 100 
    self.update_attribute :avg_proficiency, score 
  end 

  private 
    def seal 
      self.create_sku path: "skills/#{self.id}"
      self.update_attributes uid: "#{self.chapter.uid}-#{self.id}", generic: (self.chapter_id == Chapter.generic.id)
    end 

    def set_sku_ownership 
      self.generic = self.chapter_id == Chapter.generic.id 

      old_uid = self.uid 
      self.uid = (self.chapter_id == 0 || self.chapter_id.nil?) ? nil : "#{self.chapter.uid}-#{self.id}" 

      yield 

      self.sku.reassign_to_zips 
      Question.replaceTagXWithY old_uid, self.uid 

    end # of method  

end
