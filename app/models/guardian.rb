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
  has_one :account, as: :loggable, dependent: :destroy
  validates_associated :account

  # [:all] ~> [:admin, :guardian, :teacher, :school]
  #attr_accessible
end
