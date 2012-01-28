# == Schema Information
#
# Table name: testpapers
#
#  id         :integer         not null, primary key
#  quiz_id    :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Testpaper < ActiveRecord::Base
  belongs_to :quiz
  has_many :graded_responses

  has_many :course_packs
  has_many :students, :through => :course_packs
end
