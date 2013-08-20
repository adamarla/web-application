# == Schema Information
#
# Table name: lectures
#
#  id           :integer         not null, primary key
#  lesson_id    :integer
#  milestone_id :integer
#  index        :integer         default(-1)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class Lecture < ActiveRecord::Base
  attr_accessible :index, :lesson_id, :milestone_id

  belongs_to :lesson
  belongs_to :milestone
end
