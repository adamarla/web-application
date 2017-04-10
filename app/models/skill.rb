# == Schema Information
#
# Table name: skills
#
#  id              :integer         not null, primary key
#  chapter_id      :integer
#  generic         :boolean         default(FALSE)
#  uid             :string(15)
#  author_id       :integer
#  avg_proficiency :float           default(0.0)
#  language_id     :integer         default(1)
#  has_svgs        :boolean         default(FALSE)
#

class Skill < ActiveRecord::Base
  belongs_to :chapter 
  has_one :sku, as: :stockable, dependent: :destroy

  after_create :seal
  around_update :repackage, if: :modified?

  validates :avg_proficiency, on: :update, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def revaluate_proficiency
    e = Expertise.where(skill_id: self.id) 
    return if e.blank?

    wt_tested = e.map(&:weighted_tested).inject(:+)
    return if wt_tested == 0 

    wt_correct = e.map(&:weighted_correct).inject(:+)
    score = ((wt_correct / wt_tested) * 100).round(2)
    self.update_attribute :avg_proficiency, score 
  end 

  def set_skills(ids)
    return true # do nothing 
  end 

  def tests_skill?(id) 
    return id == self.id 
  end 

  private 
    def seal 
      is_generic = self.chapter_id == Chapter.generic.id 

      self.create_sku path: "skills/#{self.id}"
      self.update_attributes uid: "#{self.chapter.uid}-#{self.id}", generic: is_generic 
    end 

    def modified? 
      return (self.chapter_id_changed? || self.has_svgs_changed? )
    end 

    def repackage 
      chapter_changed = self.chapter_id_changed? 
      if chapter_changed
        self.generic = self.chapter_id == Chapter.generic.id 
        old_uid = self.uid 
        self.uid = (self.chapter_id == 0 || self.chapter_id.nil?) ? nil : "#{self.chapter.uid}-#{self.id}" 
      end 

      yield 

      # Trigger re-packaging 
      Parcel.where(contains: "Skill").each do |p| 
        p.can_have?(self) ? p.add(self.sku) : p.remove(self.sku)
      end 

      Riddle.replace_skill_x_with_y(old_uid, self.uid) if chapter_changed

    end # of method  

end
