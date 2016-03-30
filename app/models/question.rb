# == Schema Information
#
# Table name: questions
#
#  id          :integer         not null, primary key
#  uid         :string(20)
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
  validates :uid, presence: true 
  validates :uid, uniqueness: true 

  def fastest_bingo 
    return Attempt.where(question_id: self.id).where('time_to_bingo > ?', 0).order(:time_to_bingo).first
  end 


end # of class 

