# == Schema Information
#
# Table name: questions
#
#  id            :integer         not null, primary key
#  uid           :string(255)
#  attempts      :integer         default(0)
#  created_at    :datetime
#  updated_at    :datetime
#  examiner_id   :integer
#  topic_id      :integer
#  teacher_id    :integer
#  mcq           :boolean         default(FALSE)
#  multi_correct :boolean         default(FALSE)
#  multi_part    :boolean         default(FALSE)
#  num_parts     :integer
#  difficulty    :integer         default(1)
#  half_page     :boolean         default(FALSE)
#  full_page     :boolean         default(TRUE)
#  marks         :integer
#

#     __:has_many___      __:has_many___   ____:has_many__
#    |              |    |              | |               |
#  Board --------> Courses ---------> Sp.Topics ---------> Questions
#    |               |  |               | |               |
#    |__:belongs_to__|  |___:has_many___| |__:belongs_to__|
#    

#     __:has_many_____     ___:has_many___  
#    |                |   |               | 
#  Teacher --------> Quizzes ---------> Questions 
#    |                |   |               | 
#    |__:belongs_to___|   |___:has_many___| 
#    

#     __:belongs_to___     __:belongs_to___  
#    |                |   |                | 
# Question ---------> Grade ---------> Yardstick
#    |                |   |                | 
#    |__:has_many_____|   |___:has_many____| 
#    

class Question < ActiveRecord::Base
  before_save :set_mcq_if_multi_correct

  # UID is an alphanumeric string representing the millisecond time at
  # which the folder was created in the 'vault'
  validates :uid, :uniqueness => true, :presence => true
  validates :num_parts, :numericality => {:only_integer => true, :greater_than => 0}, :if => :multi_part?

  belongs_to :examiner
  belongs_to :topic
  belongs_to :teacher # non-nil if question came from a teacher

  has_many :q_selections
  has_many :quizzes, :through => :q_selections
  has_many :graded_responses

  def mcq? 
    return mcq
  end 

  def multi_part?
    return multi_part
  end 

  def num_parts?
    return (num.parts.nil? ? 0 : num_parts)
  end 

  def set_mcq_if_multi_correct
    self.mcq = (self.mcq || self.multi_correct)
    return true 
    # if self.mcq results to 'false' and the 'false' is then returned, 
    # then the save operation would be aborted (needlessly)
  end

  def set_length_and_marks(length, marks)
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['tag_question']}" 
    response = SavonClient.request :wsdl, :tag_question do  
      soap.body = { 
         :id => self.uid,
         :marks => marks,
         :length => length
      }
     end # of response 
     # As long as the response does not have an error, we are good
     return response[:tag_question_response][:manifest]
  end

end
