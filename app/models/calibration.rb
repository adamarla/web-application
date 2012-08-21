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

  def self.mcqs
    where("mcq_id IS NOT ?", nil)
  end

  def self.define_using_ids(insight, formulation, calculation, allotment)
    c = Calibration.new :insight_id => insight, :formulation_id => formulation, 
                        :calculation_id => calculation, :allotment => allotment
    c.save
  end

  def self.fair_value_for(bottomline, formulation = nil, calculation = nil)
    # Arguments are Yardstick objects 
    fair_value = 0 

    if bottomline.mcq
       case bottomline.weight
         when 0,1 then fair_value = 0
         when 2 then fair_value = 60
         when 3 then fair_value = 100
       end 
    else
      case bottomline.weight 
        when 0 then fair_value = 0 
        when 1 then fair_value = 10
        when 2 then fair_value = 35
        when 3 then fair_value = 50
      end 

      case formulation.weight
        when 1 then fair_value += 10 
        when 2 then fair_value += 20
        when 3 then fair_value += 40
      end 

      case calculation.weight
        when 2 then fair_value += 10
      end 
    end
    return fair_value 
  end

  def self.define_using(bottomline, formulation = nil, calculation = nil)
    # Arguments are yardstick objects
    v = Calibration.fair_value_for bottomline, formulation, calculation
    c = Calibration.new :insight_id => bottomline.id, :formulation_id => formulation.id,
                        :calculation_id => calculation.id, :allotment => v
    c.save
  end 

  def self.build_viable_calibrations
    insights = Yardstick.insights
    formulations = Yardstick.formulations
    calculations = Yardstick.calculations

    insights.each do |i|
      formulations.each do |f| 
        calculations.each do |c| 
          cb = Calibration.define_using i,f,c
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
      2 => partially correct & partially complete
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

  def weights?
    if self.mcq_id.nil?
      i = Yardstick.where(:id => self.insight_id).map(&:weight).first
      f = Yardstick.where(:id => self.formulation_id).map(&:weight).first
      c = Yardstick.where(:id => self.calculation_id).map(&:weight).first

      return [i,f,c]
    else
      m = Yardstick.where(:id => self.mcq_id).map(&:weight).first
      return [m]
    end
  end

  def colour?
    weights = self.weights?
    colour = :undefined 

    if self.mcq_id.nil? 
      cumulative = weights[0] + weights[1] # insight + formulation
      if cumulative < 3
        colour = :pink
      elsif cumulative < 6 
        colour = :orange 
      else
        colour = :green
      end
    else
      case weights[0] # just mcq
        when 0,1 then colour = :lightblue 
        else colour = :blue
      end
    end
  end # of method

  def non_null_indices 
    return self.mcq_id.nil? ? [self.insight_id, self.formulation_id, self.calculation_id] : [self.mcq_id]
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
