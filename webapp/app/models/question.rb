# == Schema Information
#
# Table name: questions
#
#  id                :integer         not null, primary key
#  path              :string(255)
#  attempts          :integer         default(0)
#  created_at        :datetime
#  updated_at        :datetime
#  examiner_id       :integer
#  specific_topic_id :integer
#  teacher_id        :integer
#  mcq               :boolean         default(FALSE)
#  multi_correct     :boolean         default(FALSE)
#  multi_part        :boolean         default(FALSE)
#  num_parts         :integer
#  difficulty        :integer         default(1)
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
  
  validates :multi_correct, :inclusion => {:in => [false], 
  :message => "'multi_correct' has to false if mcq == false"}, :unless => :mcq?

  validates :num_parts, :numericality => {:only_integer => true, :greater_than => 0}, :if => :multi_part?

  # 'path' is relative to some root and should be of the form 'dir/dir/something'
  validates :path, :presence => true, 
            :format => { :with => /\A[\/\w\d]+\z/, 
                         :message => "Should be a valid UNIX path" }
  
  belongs_to :examiner
  belongs_to :specific_topic
  belongs_to :teacher # non-nil if question came from a teacher
  has_many :quizzes, :through => :q_selections
  has_many :graded_responses

  attr_accessible :path, :examiner_id, :specific_topic_id, :teacher_id

  def mcq? 
    return mcq
  end 

  def multi_part?
    return multi_part
  end 

  def num_parts?
    return (num.parts.nil? ? 0 : num_parts)
  end 

end
