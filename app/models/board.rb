# == Schema Information
#
# Table name: boards
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

#     __:has_many___      __:has_many___   ____:has_many__
#    |              |    |              | |               |
#  Board --------> Courses ---------> Sp.Topics ---------> Questions
#    |               |  |               | |               |
#    |__:belongs_to__|  |___:has_many___| |__:belongs_to__|
#    

class Board < ActiveRecord::Base
  has_many :courses
  validates :name, :presence => true

  # [:name] ~> [:admin] 
  #attr_accessible

  def schools (active = true)
    a = Account.where(:loggable_type => 'School').where(:active => active).select(:loggable_id)
    School.where(:board_id => self.id, :id => a)
  end 

end
