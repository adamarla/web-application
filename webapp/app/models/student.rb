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
  has_one :account
end
