# == Schema Information
#
# Table name: topics
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

#     __:has_many__      __:has_many__     __:has_many__
#    |             |    |             |   |             |
#  Board --------> Syllabi ---------> Topics ---------> Db_Questions
#    |               |  |               | |               |
#    |__:belongs_to__|  |___:has_many___| |__:belongs_to__|
#    

class Topic < ActiveRecord::Base
  validates :name, :presence => true
end
