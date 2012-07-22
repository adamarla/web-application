# == Schema Information
#
# Table name: student_rosters
#
#  id         :integer         not null, primary key
#  student_id :integer
#  sektion_id :integer
#

class StudentRoster < ActiveRecord::Base
  belongs_to :student
  belongs_to :sektion
end
