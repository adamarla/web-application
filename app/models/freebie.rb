# == Schema Information
#
# Table name: freebies
#
#  id         :integer         not null, primary key
#  course_id  :integer
#  lesson_id  :integer
#  index      :integer         default(0)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Freebie < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :course
  belongs_to :lesson
end
