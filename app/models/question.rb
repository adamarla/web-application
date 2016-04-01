# == Schema Information
#
# Table name: questions
#
#  id          :integer         not null, primary key
#  n_picked    :integer         default(0)
#  created_at  :datetime
#  updated_at  :datetime
#  examiner_id :integer
#  topic_id    :integer
#  difficulty  :integer         default(1)
#  available   :boolean         default(TRUE)
#  potd        :boolean         default(FALSE)
#  num_potd    :integer         default(0)
#


class Question < ActiveRecord::Base

  def fastest_bingo 
    return Attempt.where(question_id: self.id).where('time_to_bingo > ?', 0).order(:time_to_bingo).first
  end 

  def path 
    return "q/#{self.examiner_id}/#{self.id}"
  end 


end # of class 

