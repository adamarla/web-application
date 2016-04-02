# == Schema Information
#
# Table name: snippets
#
#  id            :integer         not null, primary key
#  examiner_id   :integer
#  skill_id      :integer
#  num_attempted :integer         default(0)
#  num_correct   :integer         default(0)
#

class Snippet < ActiveRecord::Base
  belongs_to :skill

  def path 
    return "snippets/#{self.id}"
  end 

  def attempted(correctly = false) 
    correctly ? self.update_attributes(num_attempted: self.num_attempted + 1, 
                                       num_correct: self.num_correct + 1)
              : self.update_attribute(:num_attempted, self.num_attempted + 1)
  end 

end
