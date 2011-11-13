# == Schema Information
#
# Table name: syllabi
#
#  id         :integer         not null, primary key
#  course_id  :integer
#  topic_id   :integer
#  created_at :datetime
#  updated_at :datetime
#  difficulty :integer         default(0)
#

class Syllabus < ActiveRecord::Base
  belongs_to :course 
  belongs_to :topic
end
