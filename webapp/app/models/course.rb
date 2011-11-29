# == Schema Information
#
# Table name: courses
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  board_id   :integer
#  klass      :integer
#  subject_id :integer
#  created_at :datetime
#  updated_at :datetime
#  active     :boolean         default(TRUE)
#

#     __:has_many___      __:has_many___   ____:has_many__
#    |              |    |              | |               |
#  Board --------> Courses ---------> Sp.Topics ---------> Questions
#    |               |  |               | |               |
#    |__:belongs_to__|  |___:has_many___| |__:belongs_to__|
#    

class Course < ActiveRecord::Base
  belongs_to :board 
  belongs_to :subject

  has_many :specific_topics, :through => :syllabi
  has_many :syllabi

  validates :name, :presence => true
  validates :klass, :presence => true, \
            :numericality => {:only_integer => true, :greater_than => 0}
  validates :subject_id, :board_id, :presence => true

  scope :for_klass, lambda { |g| (g.nil? || g[:klass].empty?) ? 
                             where('klass IS NOT NULL') : 
                             where(:klass => g[:klass].to_i) } 

  scope :for_subject, lambda { |g| (g.nil? || g[:subject].empty?) ? 
                               where('subject_id IS NOT NULL') : 
                               where(:subject_id => g[:subject].to_i) }

  scope :in_board, lambda { |g| (g.nil? || g[:board].empty?) ? 
                             where('board_id IS NOT NULL') : 
                             where(:board_id => g[:board].to_i) } 
  
  # [:name,:board_id,:klass,:subject] ~> [:admin] 
  #attr_accessible 

end
