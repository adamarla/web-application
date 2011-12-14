# == Schema Information
#
# Table name: broad_topics
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class BroadTopic < ActiveRecord::Base
  has_many :specific_topics 

  validates :name, :presence => true
end
