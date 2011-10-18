# == Schema Information
#
# Table name: parents
#
#  id         :integer         not null, primary key
#  is_mother  :boolean
#  created_at :datetime
#  updated_at :datetime
#

class Parent < ActiveRecord::Base
  has_many :students
end
