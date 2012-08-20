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
#

#     ___:has_many____     __:belongs_to___    ____:has_many____
#    |                |   |                |  |                 |
# Teacher ---------> Grade ---------> Calibration ---------> Yardsticks
#    |                |   |                |  |                 |
#    |__:belongs_to___|   |___:has_many____|  |____:has_many____|
#    

class Calibration < ActiveRecord::Base
  validates :allotment, :numericality => { :only_integer => true, :less_than => 101, :greater_than => -1 }

  before_save :check_viability
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

  def self.define_using_ids(insight, formulation, calculation, allotment)
    c = Calibration.new :insight_id => insight, :formulation_id => formulation, 
                        :calculation_id => calculation, :allotment => allotment
    c.save
  end

  def self.build_viable_calibrations
    insights = Yardstick.insights.map(&:id)
    formulations = Yardstick.formulations.map(&:id)
    calculations = Yardstick.calculations.map(&:id)
    a = 50

    insights.each do |i|
      formulations.each do |f| 
        calculations.each do |c| 
          cb = Calibration.define_using_ids i,f,c,a  
        end 
      end 
    end # insights
  end

  def viable?
    return true unless self.mcq_id.nil? 

    insight = Yardstick.find self.insight_id 
    formulation = Yardstick.find self.formulation_id 
    calculation = Yardstick.find self.calculation_id 
    
=begin
    Broadly speaking, a formulation cannot be better than insight
    and calculation cannot be better than formulation

    We use a 4-point scale for insights & formulations:
      0 => blank / missing / irrelevant 
      1 => plain wrong 
      2 => partially correct 
      3 => fully correct

    We use a 3-point scale for calculations
      0 => doesn't matter / irrelevant in present case 
      1 => some errors 
      2 => no errors
=end

    return false if formulation.weight > insight.weight
    return false if calculation.weight > formulation.weight

    if insight.weight < 3
      # Calculation irrelevant if no/partial insight
      return false if calculation.weight != 0
      # No formulation <=> no insight & partial formulation <=> partial insight
      return false if formulation.weight != insight.weight
    else
      # full insight => some fomulation => calculation is NOT irrelevant
      return false if calculation.weight == 0
      # full insight => some formulation atleast
      return false if formulation.weight < 2
    end 
    return true
  end

  def decompile
    if self.mcq_id.nil?
      Yardstick.where(:id => [self.insight_id, self.formulation_id, self.calculation_id]).map(&:meaning)
    else
      Yardstick.where(:id => self.mcq_id).map(&:meaning)
    end
  end

  private
    
    def add_for_every_teacher
    end 

    def check_viability
      self.viable?
    end

end
