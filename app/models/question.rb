# == Schema Information
#
# Table name: questions
#
#  id          :integer         not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  examiner_id :integer
#  difficulty  :integer         default(1)
#  live        :boolean         default(FALSE)
#  potd        :boolean         default(FALSE)
#  num_potd    :integer         default(0)
#  chapter_id  :integer
#  language_id :integer
#


class Question < ActiveRecord::Base
  belongs_to :chapter 
  belongs_to :language

  def fastest_bingo 
    return Attempt.where(question_id: self.id).where('time_to_bingo > ?', 0).order(:time_to_bingo).first
  end 

  def path 
    return "q/#{self.examiner_id}/#{self.id}"
  end 


end # of class 

