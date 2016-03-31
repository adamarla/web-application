# == Schema Information
#
# Table name: levels
#
#  id   :integer         not null, primary key
#  name :string(30)
#

class Level < ActiveRecord::Base
  validates :name, presence: true 
  validates :name, uniqueness: true 

  before_validation :titleize 

  def titleize 
    self.name = self.name.titleize 
  end 

  def self.named(name)
    l = where(name: name.titleize)
    return (l.empty? ? 0 : l.map(&:id).first)
  end 
end
