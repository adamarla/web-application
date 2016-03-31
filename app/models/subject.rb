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
  after_create :titleize

  def titleize 
    self.update_attribute :name, self.name.titleize 
  end 

end
