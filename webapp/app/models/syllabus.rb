# == Schema Information
#
# Table name: syllabi
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  board_id   :integer
#  grade      :integer
#  subject    :integer
#  created_at :datetime
#  updated_at :datetime
#

#     __:has_many__      __:has_many__     __:has_many__
#    |             |    |             |   |             |
#  Board --------> Syllabi ---------> Topics ---------> Db_Questions
#    |               |  |               | |               |
#    |__:belongs_to__|  |___:has_many___| |__:belongs_to__|
#    

class Syllabus < ActiveRecord::Base
  belongs_to :board 
  validates :name, :presence => true
  validates :grade, :presence => true, \
            :numericality => {:only_integer => true, :greater_than => 0}
  validates :subject, :presence => true, \
            :numericality => {:only_integer => true, :greater_than => 0}
end
