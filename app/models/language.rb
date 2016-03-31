class Language < ActiveRecord::Base
  validates :name, presence: true 
  validates :name, uniqueness: true 

  before_validation :titleize 

  def titleize 
    self.name = self.name.titleize 
  end 

end
