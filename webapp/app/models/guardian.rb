# == Schema Information
#
# Table name: guardians
#
#  id         :integer         not null, primary key
#  is_mother  :boolean
#  created_at :datetime
#  updated_at :datetime
#

class Guardian < ActiveRecord::Base
  has_many :students
  has_one :account, :dependent => :destroy
end
