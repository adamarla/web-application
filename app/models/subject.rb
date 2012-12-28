# == Schema Information
#
# Table name: subjects
#
#  id         :integer         not null, primary key
#  name       :string(30)
#  created_at :datetime
#  updated_at :datetime
#

class Subject < ActiveRecord::Base
  has_many :courses

  has_many :specializations
  has_many :teachers, :through => :specializations

  validates :name, :presence => true
end
