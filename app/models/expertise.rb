# == Schema Information
#
# Table name: expertise
#
#  id               :integer         not null, primary key
#  user_id          :integer
#  skill_id         :integer
#  num_tested       :integer         default(0)
#  num_correct      :integer         default(0)
#  weighted_tested  :float           default(0.0)
#  weighted_correct :float           default(0.0)
#

class Expertise < ActiveRecord::Base
  belongs_to :user 
  belongs_to :skill 

  validates :skill_id, uniqueness: { scope: [:user_id] }

  def decompile
    p = self.skill 

    return { 
      skill_id: self.skill_id, 
      chapter_id: p.chapter_id, 
      avg_proficiency: p.avg_proficiency,
      num_tested: self.num_tested, 
      num_correct: self.num_correct, 
      weighted_tested: self.weighted_tested, 
      weighted_correct: self.weighted_correct
    } 
  end 

end
