# == Schema Information
#
# Table name: quizzes
#
#  id            :integer         not null, primary key
#  teacher_id    :integer
#  created_at    :datetime
#  updated_at    :datetime
#  num_questions :integer
#  name          :string(255)
#

#     __:has_many_____     ___:has_many___  
#    |                |   |               | 
#  Teacher --------> Quizzes ---------> Questions 
#    |                |   |               | 
#    |__:belongs_to___|   |___:has_many___| 
#    

class Quiz < ActiveRecord::Base
  belongs_to :teacher 

  has_many :q_selections
  has_many :questions, :through => :q_selections

  has_many :graded_responses
  has_many :students, :through => :graded_responses

  validates :teacher_id, :presence => true, :numericality => true
  validates :name, :presence => true

  def prepare_for(students)
    # students : an array of selected students from the DB
  end 

  def teacher 
    Teacher.find self.teacher_id
  end 

  def set_name( klass, subject )
    return false if (klass.blank? || subject.blank?)
    timestamp = "(#{Date.today.strftime '%b %d, %Y'})"
    self.name = "#{subject[0]}#{klass} #{timestamp}"
  end 

end
