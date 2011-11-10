# == Schema Information
#
# Table name: grade_descriptions
#
#  id                :integer         not null, primary key
#  annotation        :string(255)
#  description       :string(255)
#  default_allotment :integer
#  created_at        :datetime
#  updated_at        :datetime
#

class GradeDescription < ActiveRecord::Base
  has_many :grades
  has_many :teachers, :through => :grades 
end
