# == Schema Information
#
# Table name: questions
#
#  id          :integer         not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  examiner_id :integer
#  difficulty  :integer         default(1)
#  live        :boolean         default(FALSE)
#  potd        :boolean         default(FALSE)
#  num_potd    :integer         default(0)
#  chapter_id  :integer
#  language_id :integer
#


class Question < ActiveRecord::Base
  belongs_to :chapter 
  belongs_to :language
  has_one :sku, as: :stockable, dependent: :destroy

  around_update :edit_zips, if: :retagged?
  after_create :add_sku 

  acts_as_taggable_on :skills

  def fastest_bingo 
    return Attempt.where(question_id: self.id).where('time_to_bingo > ?', 0).order(:time_to_bingo).first
  end 

  def set_skills(skill_ids) 
    return false if skill_ids.blank?
    uids = Skill.where(id: skill_ids).map(&:uid).join(',')
    self.skill_list = uids 
    self.save 
  end 

  def self.with_skills(skill_ids)
    # Only consider questions that belong to the same Chapters 
    # as the passed Skills

    cids = Skill.where(id: skill_ids).map(&:chapter_id).uniq 
    skills = Skill.where(id: skill_ids).map(&:uid)
    return Question.where(chapter_id: cids).tagged_with(skills, any: true, on: :skills)
  end 

  private 
    def add_sku 
      self.create_sku path: "q/#{self.examiner_id}/#{self.id}"
    end 

    def retagged?
      return (self.difficulty_changed? || self.chapter_id_changed? || self.language_id_changed?)
    end 

    def edit_zips
      yield 
      self.sku.edit_zips
    end 


end # of class 

