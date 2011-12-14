# == Schema Information
#
# Table name: syllabi
#
#  id                :integer         not null, primary key
#  course_id         :integer
#  specific_topic_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#  difficulty        :integer         default(1)
#

class Syllabus < ActiveRecord::Base
  belongs_to :course 
  belongs_to :specific_topic
end
