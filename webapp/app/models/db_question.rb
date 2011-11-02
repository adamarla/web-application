# == Schema Information
#
# Table name: db_questions
#
#  id          :integer         not null, primary key
#  path        :string(255)
#  attempts    :integer         default(0)
#  flags       :integer         default(0)
#  created_at  :datetime
#  updated_at  :datetime
#  examiner_id :integer
#  topic_id    :integer
#

class DbQuestion < ActiveRecord::Base
  
  # 'path' is relative to some root and should be of the form 'dir/dir/something'
  validates :path, :presence => true, 
            :format => { :with => /\A([\/]?[-\w\d]+)*/, 
                         :message => "Should be a valid UNIX path" }
  
  has_many :questions # rather, instances of this question in various quizzes
  belongs_to :examiner
  belongs_to :topic

end
