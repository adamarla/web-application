# == Schema Information
#
# Table name: courses
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  board_id   :integer
#  grade      :integer
#  subject    :integer
#  created_at :datetime
#  updated_at :datetime
#

#     __:has_many___      __:has_many___   ____:has_many__
#    |              |    |              | |               |
#  Board --------> Courses ---------> Topics ---------> Db_Questions
#    |               |  |               | |               |
#    |__:belongs_to__|  |___:has_many___| |__:belongs_to__|
#    

class Course < ActiveRecord::Base
  belongs_to :board 

  has_many :topics, :through => :syllabi
  has_many :syllabi

  validates :name, :presence => true
  validates :grade, :presence => true, \
            :numericality => {:only_integer => true, :greater_than => 0}
  validates :subject, :presence => true, \
            :numericality => {:only_integer => true, :greater_than => 0}
end
