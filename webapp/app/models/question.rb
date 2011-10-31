# == Schema Information
#
# Table name: questions
#
#  id             :integer         not null, primary key
#  created_at     :datetime
#  updated_at     :datetime
#  favourite      :boolean         default(FALSE)
#  db_question_id :integer
#  teacher_id     :integer
#  times_used     :integer         default(0)
#  quiz_id        :integer
#

class Question < ActiveRecord::Base
  belongs_to :db_question 
  belongs_to :teacher 
  belongs_to :quiz

  scope :favourited, where( :favourite => true )

  def favourite?
    return self.favourite
  end

  def path 
    return self.db_question.path
  end 

end
