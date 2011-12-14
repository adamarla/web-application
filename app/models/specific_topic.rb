# == Schema Information
#
# Table name: specific_topics
#
#  id             :integer         not null, primary key
#  name           :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  broad_topic_id :integer
#

#     __:has_many___      __:has_many___   ____:has_many__
#    |              |    |              | |               |
#  Board --------> Courses ---------> Sp.Topics ---------> Questions
#    |               |  |               | |               |
#    |__:belongs_to__|  |___:has_many___| |__:belongs_to__|
#    

class SpecificTopic < ActiveRecord::Base
  validates :name, :presence => true

  has_many :courses, :through => :syllabi
  has_many :syllabi
  belongs_to :broad_topic
end
