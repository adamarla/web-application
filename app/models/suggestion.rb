# == Schema Information
#
# Table name: suggestions
#
#  id            :integer         not null, primary key
#  teacher_id    :integer
#  examiner_id   :integer
#  completed     :boolean         default(FALSE)
#  created_at    :datetime
#  updated_at    :datetime
#  filesignature :string(255)
#

class Suggestion < ActiveRecord::Base
  
  has_many :questions
  belongs_to :teacher  
  
  def self.unassigned
    where(:examiner_id => nil)
  end  
  
  def update( question_id )
  	qs = Question.find_by_suggestion_id( self[:id] )
  	qs.each do |q|
  	  break unless q[:topic_id].nil
  	end  	  	
  	self.complete
  end
  
  private
    def complete      
      self[:complete] = true
      Mailbot.suggestion_accepted(self).deliver if self.save
    end
    
end
