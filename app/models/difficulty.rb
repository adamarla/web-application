# == Schema Information
#
# Table name: difficulties
#
#  id    :integer         not null, primary key
#  name  :string(50)
#  level :integer
#

class Difficulty < ActiveRecord::Base
  validates :name, presence: true 
  validates :name, uniqueness: true 
  validates :level, uniqueness: true
end
