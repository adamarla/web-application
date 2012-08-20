# == Schema Information
#
# Table name: yardsticks
#
#  id          :integer         not null, primary key
#  mcq         :boolean         default(FALSE)
#  meaning     :string(255)
#  insight     :boolean         default(FALSE)
#  formulation :boolean         default(FALSE)
#  calculation :boolean         default(FALSE)
#  weight      :integer         default(1)
#

#     __:belongs_to___     __:belongs_to___  
#    |                |   |                | 
# Question ---------> Grade ---------> Calibration
#    |                |   |                | 
#    |__:has_many_____|   |___:has_many____| 
#    

#     ___:has_many____     __:belongs_to___    ____:has_many____
#    |                |   |                |  |                 |
# Teacher ---------> Grade ---------> Calibration ---------> Yardsticks
#    |                |   |                |  |                 |
#    |__:belongs_to___|   |___:has_many____|  |____:has_many____|
#    

class Yardstick < ActiveRecord::Base
  validates :meaning, :presence => true
  validates :weight, :numericality => { :only_integer => true, :greater_than => -1, :less_than => 4 }

  # [:all] ~> [:admin]
  #attr_accessible

  def self.insights
    where(:insight => true)
  end

  def self.formulations
    where(:formulation => true)
  end

  def self.calculations
    where(:calculation => true)
  end

  def self.mcqs
    where(:mcq => true)
  end

  def self.weight(n)
    where(:weight => (n.nil? ? 0 : n))
  end

  def self.atmost(n)
    where("weight <= ?", (n.nil? ? 0 : n))
  end

  def self.atleast(n)
    where("weight >= ?", (n.nil? ? 0 : n))
  end

end
