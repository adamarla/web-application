# == Schema Information
#
# Table name: suggestions
#
#  id          :integer         not null, primary key
#  teacher_id  :integer
#  examiner_id :integer
#  completed   :boolean         default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#  signature   :string(255)
#

class Suggestion < ActiveRecord::Base
  
  has_many :questions
  belongs_to :teacher  
  
  def self.unassigned
    where(:examiner_id => nil)
  end  

  def check_for_completeness
    return true if self.completed 
    untagged = Question.where(:suggestion_id => self.id).untagged 
    if untagged.count == 0
      Mailbot.suggestion_typeset(self).deliver if self.update_attribute(:completed, true)
    end
    return false
  end

  def days_since_receipt
    return (Date.today - self.created_at.to_date).to_i
  end

end # of class
