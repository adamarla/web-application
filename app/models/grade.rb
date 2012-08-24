# == Schema Information
#
# Table name: grades
#
#  id             :integer         not null, primary key
#  allotment      :float
#  yardstick_id   :integer
#  teacher_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  calibration_id :integer
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
  belongs_to :calibration

  # [:all] ~> [:admin, :teacher]
  #attr_accessible
  def colour?
    self.calibration_id.nil? ? nil : self.calibration.colour?
  end 

end
