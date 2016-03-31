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
  validates :name, presence: true 
  validates :name, uniqueness: true 

  before_validation :titleize 

  def titleize 
    self.name = self.name.titleize 
  end 

  def self.named(name)
    s = where(name: name.titleize)
    return (s.empty? ? 0 : s.map(&:id).first)
  end 

end
