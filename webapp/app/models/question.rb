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

class Question < ActiveRecord::Base
  
  # 'path' is relative to some root and should be of the form 'dir/dir/something'
  validates :path, :presence => true, 
            :format => { :with => /\A([\/]?[-\w\d]+)*/, 
                         :message => "Should be a valid UNIX path" }
  
  belongs_to :examiner
  belongs_to :topic
  belongs_to :teacher # non-nil if question came from a teacher
  has_many :quizzes, :through => :q_selections

end
