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
  has_many :quizzes 
  has_many :questions, :through => :quizzes
  belongs_to :school 
  has_one :account
end
