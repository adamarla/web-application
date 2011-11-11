# == Schema Information
#
# Table name: q_selections
#
#  id          :integer         not null, primary key
#  quiz_id     :integer
#  question_id :integer
#  page        :integer
#  created_at  :datetime
#  updated_at  :datetime
#

#     __:has_many_____     ___:has_many___  
#    |                |   |               | 
#  Teacher --------> Quizzes ---------> Questions 
#    |                |   |               | 
#    |__:belongs_to___|   |___:has_many___| 
#    

class QSelection < ActiveRecord::Base
  belongs_to :quiz
  belongs_to :question

  # [:all] ~> [:admin, :teacher]
  #attr_accessible 
end
