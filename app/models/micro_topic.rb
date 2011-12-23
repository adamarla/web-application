# == Schema Information
#
# Table name: micro_topics
#
#  id             :integer         not null, primary key
#  name           :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  macro_topic_id :integer
#

#     __:has_many___      __:has_many___   ____:has_many__
#    |              |    |              | |               |
#  Board --------> Courses ---------> Sp.Topics ---------> Questions
#    |               |  |               | |               |
#    |__:belongs_to__|  |___:has_many___| |__:belongs_to__|
#    

class MicroTopic < ActiveRecord::Base
  validates :name, :presence => true

  has_many :courses, :through => :syllabi
  has_many :syllabi
  belongs_to :macro_topic
end
