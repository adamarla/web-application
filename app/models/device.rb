# == Schema Information
#
# Table name: devices
#
#  id         :integer         not null, primary key
#  pupil_id   :integer
#  gcm_token  :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Device < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :gcm_token, presence: true 
  belongs_to :pupil 
end
