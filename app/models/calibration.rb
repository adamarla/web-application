# == Schema Information
#
# Table name: calibrations
#
#  id             :integer         not null, primary key
#  insight_id     :integer
#  formulation_id :integer
#  calculation_id :integer
#  mcq_id         :integer
#  allotment      :integer
#  example        :string(255)
#

#     ___:has_many____     __:belongs_to___    ____:has_many____
#    |                |   |                |  |                 |
# Teacher ---------> Grade ---------> Calibration ---------> Yardsticks
#    |                |   |                |  |                 |
#    |__:belongs_to___|   |___:has_many____|  |____:has_many____|
#    

class Calibration < ActiveRecord::Base
  validates :allotment, :numericality => { :only_integer => true, :less_than => 101, :greater_than => -1 }
  after_create :add_for_every_teacher

  def self.with_atmost(params = {})
    i = Yardstick.insights.atmost(params[:insight]).map(&:id)
    f = Yardstick.formulations.atmost(params[:formulation]).map(&:id)
    c = Yardstick.calculations.atmost(params[:calculation]).map(&:id)

    where(:insight_id => i, :formulation_id => f, :calculation_id => c)
  end

  def self.with_atleast(params = {})
    i = Yardstick.insights.atleast(params[:insight]).map(&:id)
    f = Yardstick.formulations.atleast(params[:formulation]).map(&:id)
    c = Yardstick.calculations.atleast(params[:calculation]).map(&:id)

    where(:insight_id => i, :formulation_id => f, :calculation_id => c)
  end

  def self.mcqs
    where("mcq_id IS NOT ?", nil)
  end

  private
    
    def add_for_every_teacher
    end 

end
