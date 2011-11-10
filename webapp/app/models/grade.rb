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

class Grade < ActiveRecord::Base
  belongs_to :teacher 
  belongs_to :grade_description
end
