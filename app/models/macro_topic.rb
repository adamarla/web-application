# == Schema Information
#
# Table name: macro_topics
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class MacroTopic < ActiveRecord::Base
  has_many :micro_topics 

  validates :name, :presence => true
end
