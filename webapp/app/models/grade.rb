# == Schema Information
#
# Table name: grades
#
#  id                   :integer         not null, primary key
#  allotment            :integer
#  grade_description_id :integer
#  teacher_id           :integer
#  created_at           :datetime
#  updated_at           :datetime
#

#     __:belongs_to___     __:belongs_to___  
#    |                |   |                | 
# Question ---------> Grade ---------> GradeDesc
#    |                |   |                | 
#    |__:has_many_____|   |___:has_many____| 
#    

#     ___:has_many____     __:belongs_to___  
#    |                |   |                | 
# Teacher ---------> Grade ---------> GradeDesc
#    |                |   |                | 
#    |__:belongs_to___|   |___:has_many____| 
#    
class Grade < ActiveRecord::Base
  belongs_to :teacher 
  belongs_to :grade_description
end
