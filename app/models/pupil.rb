# == Schema Information
#
# Table name: pupils
#
#  id         :integer         not null, primary key
#  first_name :string(50)
#  last_name  :string(50)
#  email      :string(100)
#  gender     :integer
#  birthday   :string(50)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Pupil < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :email, presence: true
  validates :email, uniqueness: true 

  has_many :attempts, dependent: :destroy
  has_many :devices, dependent: :destroy
end
