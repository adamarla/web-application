# == Schema Information
#
# Table name: expertise
#
#  id          :integer         not null, primary key
#  pupil_id    :integer
#  skill_id    :integer
#  num_tested  :integer         default(0)
#  num_correct :integer         default(0)
#

class Expertise < ActiveRecord::Base
  belongs_to :pupil 
  belongs_to :skill 

  validates :skill_id, uniqueness: { scope: [:pupil_id] }

end
