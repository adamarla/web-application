# == Schema Information
#
# Table name: courses
#
#  id          :integer         not null, primary key
#  title       :string(150)
#  description :text
#  teacher_id  :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Course < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :teacher

  has_many :freebies, dependent: :destroy
  has_many :lessons, through: :freebies

  has_many :takehomes, dependent: :destroy 
  has_many :quizzes, through: :takehomes
end
