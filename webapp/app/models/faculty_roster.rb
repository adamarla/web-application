# == Schema Information
#
# Table name: faculty_rosters
#
#  id             :integer         not null, primary key
#  study_group_id :integer
#  teacher_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class FacultyRoster < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :study_group

  # [:all] ~> [:school, :admin, :teacher]
  #attr_accessible 
end
