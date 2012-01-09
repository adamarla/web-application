# == Schema Information
#
# Table name: quizzes
#
#  id            :integer         not null, primary key
#  teacher_id    :integer
#  created_at    :datetime
#  updated_at    :datetime
#  num_questions :integer
#

#     __:has_many_____     ___:has_many___  
#    |                |   |               | 
#  Teacher --------> Quizzes ---------> Questions 
#    |                |   |               | 
#    |__:belongs_to___|   |___:has_many___| 
#    

class Quiz < ActiveRecord::Base
  belongs_to :teacher 
  has_many :questions, :through => :q_selections

  has_many :graded_responses
  has_many :students, :through => :graded_responses

  validates :teacher_id, :presence => true, :numericality => true

  after_create :set_uid

  def prepare_for(students)
    # students : an array of selected students from the DB
  end 

  def teacher 
    Teacher.find self.teacher_id
  end 

end
