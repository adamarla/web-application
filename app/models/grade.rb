# == Schema Information
#
# Table name: grades
#
#  id           :integer         not null, primary key
#  allotment    :integer
#  yardstick_id :integer
#  teacher_id   :integer
#  created_at   :datetime
#  updated_at   :datetime
#

#     __:belongs_to___     __:belongs_to___  
#    |                |   |                | 
# Question ---------> Grade ---------> Yardstick
#    |                |   |                | 
#    |__:has_many_____|   |___:has_many____| 
#    

#     ___:has_many____     __:belongs_to___    ____:has_many____
#    |                |   |                |  |                 |
# Teacher ---------> Grade ---------> Calibration ---------> Yardsticks
#    |                |   |                |  |                 |
#    |__:belongs_to___|   |___:has_many____|  |____:has_many____|
#    

class Grade < ActiveRecord::Base
  belongs_to :teacher 
  belongs_to :yardstick

  # [:all] ~> [:admin, :teacher]
  #attr_accessible
end
