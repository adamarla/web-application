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
  # A parent is always a parent. If parent goes, so do the kids/students
  has_many :students, :dependent => :destroy 
  has_one :account, :dependent => :destroy
end
