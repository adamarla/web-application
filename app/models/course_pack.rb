# == Schema Information
#
# Table name: course_packs
#
#  id           :integer         not null, primary key
#  student_id   :integer
#  testpaper_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class CoursePack < ActiveRecord::Base
  belongs_to :student
  belongs_to :course_pack 
end
