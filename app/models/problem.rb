# == Schema Information
#
# Table name: problems
#
#  id          :integer         not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  examiner_id :integer
#  difficulty  :integer         default(20)
#  chapter_id  :integer
#  language_id :integer         default(1)
#


class Problem < ActiveRecord::Base
  belongs_to :chapter 
  belongs_to :language
  has_one :sku, as: :stockable, dependent: :destroy

  around_update :repackage, if: :retagged?
  after_create :add_sku 
  before_destroy :duplicate

  acts_as_taggable_on :skills

  def path 
    return (self.sku.nil? ? "q/#{self.examiner_id}/#{self.id}" : self.sku.path)
  end 

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
    return Problem.where(chapter_id: cids).tagged_with(skills, any: true, on: :skills)
  end 

  private 
    def add_sku 
      self.create_sku path: "q/#{self.examiner_id}/#{self.id}"
    end 

    def retagged?
      return (self.difficulty_changed? || 
              self.chapter_id_changed? || 
              self.language_id_changed?)
    end 

    def repackage
      yield 
      add_sku if self.sku.nil? # for questions written before July 2016 
      self.sku.repackage
    end 

    def duplicate 
      q = Question.create original_id: self.id, 
                         chapter_id: self.chapter_id, 
                         language_id: self.language_id, 
                         difficulty: self.difficulty, 
                         examiner_id: self.examiner_id

      # Transfer skills to Question 
      q.set_skills(Skill.where(uid: self.skill_list).map(&:id))

      # Remove skills now that object is going to be destroyed 
      self.skill_list = [] 
      self.save
    end 


end # of class 

