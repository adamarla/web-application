class Teacher < ActiveRecord::Base
  has_many :quizzes 
  has_many :questions, :through => :quizzes
end
