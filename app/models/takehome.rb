# == Schema Information
#
# Table name: takehomes
#
#  id         :integer         not null, primary key
#  course_id  :integer
#  quiz_id    :integer
#  index      :integer         default(0)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  live       :boolean         default(TRUE)
#

class Takehome < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :course 
  belongs_to :quiz
end
