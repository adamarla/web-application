# == Schema Information
#
# Table name: difficulties
#
#  id      :integer         not null, primary key
#  name    :string(10)
#  meaning :string(40)
#  level   :integer
#

class Difficulty < ActiveRecord::Base
  validates :name, presence: true 
  validates :name, uniqueness: true 
  validates :level, uniqueness: true

  def self.named(name)
    l = where(name: name.downcase) 
    return (l.empty? ? 0 : l.map(&:id).first)
  end 

end
