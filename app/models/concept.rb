# == Schema Information
#
# Table name: concepts
#
#  id         :integer         not null, primary key
#  name       :string(70)
#  index      :integer         default(-1)
#  course_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Concept < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :course
  has_many :videos 
  has_many :quizzes
end
