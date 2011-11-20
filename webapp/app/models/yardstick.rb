# == Schema Information
#
# Table name: yardsticks
#
#  id                :integer         not null, primary key
#  annotation        :string(255)
#  description       :string(255)
#  default_allotment :integer
#  created_at        :datetime
#  updated_at        :datetime
#  mcq               :boolean         default(FALSE)
#  subpart           :boolean         default(FALSE)
#  active            :boolean         default(TRUE)
#

#     __:belongs_to___     __:belongs_to___  
#    |                |   |                | 
# Question ---------> Grade ---------> Yardstick
#    |                |   |                | 
#    |__:has_many_____|   |___:has_many____| 
#    

#     ___:has_many____     __:belongs_to___  
#    |                |   |                | 
# Teacher ---------> Grade ---------> Yardstick
#    |                |   |                | 
#    |__:belongs_to___|   |___:has_many____| 
#    

class Yardstick < ActiveRecord::Base
  has_many :grades
  has_many :teachers, :through => :grades 

  validates :annotation, :presence => true 
  validates :default_allotment, :presence => true, 
            :numericality => {:only_integer => true, 
                              :less_than_or_equal_to => 100}
  # [:all] ~> [:admin]
  #attr_accessible

  def applies_to 
    # Returns a string that can be used as further annotation somewhere
    self.mcq ? (self.subpart ? "mcq, subpart" : "mcq") : 
               (self.subpart ? "subpart" : "stand alone")
  end 
end
