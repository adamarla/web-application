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
      self.save
      
      #send email to teacher from examiner  
    end
        
    def send_mail
      
      return EMAIL_TEXT
    end
  
  EMAIL_TEXT = "Dear teacher_name, Thank you for the suggestions you sent us on date. " +
  				"The questions have been uploaded by us to gradians.com along with their solutions " +
  				"They will appear in your favourites when you sign in to the site and create a quiz."
   
end
