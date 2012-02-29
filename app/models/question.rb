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
  before_save :set_space_requirement

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

  def set_space_requirement
    # Ok, there should be no need for the logic below if I was 
    # ready to re-work samurai-sword to have 3 radio buttons instead of 
    # 3 checkboxes. But I am too lazy to do that
    # So, here is what we do. If 'mcq' was selected, then it sets half & full-pages to false
    # And if half-page is true, then full-page is false
    self.half_page &= !self.mcq
    self.full_page &= !self.half_page
    return true # return true lest the results of last operation abort the save 
  end

end
