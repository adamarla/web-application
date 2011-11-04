# == Schema Information
#
# Table name: questions
#
#  id          :integer         not null, primary key
#  path        :string(255)
#  attempts    :integer         default(0)
#  flags       :integer         default(0)
#  created_at  :datetime
#  updated_at  :datetime
#  examiner_id :integer
#  topic_id    :integer
#  teacher_id  :integer
#

#     __:has_many___      __:has_many___   ____:has_many__
#    |              |    |              | |               |
#  Board --------> Courses ---------> Topics ---------> Questions
#    |               |  |               | |               |
#    |__:belongs_to__|  |___:has_many___| |__:belongs_to__|
#    

#     __:has_many_____     ___:has_many___  
#    |                |   |               | 
#  Teacher --------> Quizzes ---------> Questions 
#    |                |   |               | 
#    |__:belongs_to___|   |___:has_many___| 
#    

class Question < ActiveRecord::Base
  
  # 'path' is relative to some root and should be of the form 'dir/dir/something'
  validates :path, :presence => true, 
            :format => { :with => /\A[\/\w\d]+\z/, 
                         :message => "Should be a valid UNIX path" }
  
  belongs_to :examiner
  belongs_to :topic
  belongs_to :teacher # non-nil if question came from a teacher
  has_many :quizzes, :through => :q_selections
  has_many :graded_responses

end
