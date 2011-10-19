# == Schema Information
#
# Table name: students
#
#  id         :integer         not null, primary key
#  parent_id  :integer
#  school_id  :integer
#  first_name :string(255)
#  last_name  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Student < ActiveRecord::Base
  belongs_to :parent 
  belongs_to :school 
  has_one :account, :dependent => :destroy

  # When should a student be destroyed? My guess, some fixed time after 
  # he/she graduates. But as I haven't quite decided what that time should
  # be, I am temporarily disabling all destruction

  before_destroy :destroyable? 

  private 
    def destroyable? 
      return false 
    end 
end
