# == Schema Information
#
# Table name: teachers
#
#  id         :integer         not null, primary key
#  first_name :string(255)
#  last_name  :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  school_id  :integer
#

class Teacher < ActiveRecord::Base
  has_many :quizzes, :dependent => :destroy 
  has_many :questions, :through => :quizzes
  belongs_to :school 
  has_one :account
  has_many :study_groups, :through => :faculty_rosters

  validates :first_name, :last_name, :presence => true  

  # When would one want to 'destroy' a teacher? And what would it mean? 
  # 
  # My guess is that a teacher should NEVER be 'destroyed' even if he/she 
  # is expected to quit teaching for the forseeable future (say, due to child birth). 
  # You never know, he/she might just get back to teaching. Moreover, the teacher's 
  # past record can be a good reference for the new school.

  before_destroy :destroyable? 

  private 
    def destroyable? 
      return false 
    end 

end
