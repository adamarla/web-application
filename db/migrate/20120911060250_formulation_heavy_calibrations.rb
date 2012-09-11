class FormulationHeavyCalibrations < ActiveRecord::Migration
  def up
    Calibration.define_using_ids 38, 22, 26
    Calibration.define_using_ids 38, 23, 27
    Calibration.define_using_ids 38, 23, 34
    Calibration.define_using_ids 38, 35, 27
    Calibration.define_using_ids 38, 35, 34 
    Calibration.define_using_ids 38, 24, 27
    Calibration.define_using_ids 38, 24, 34
    Calibration.define_using_ids 38, 24, 28
    Calibration.define_using_ids 38, 25, 27
    Calibration.define_using_ids 38, 25, 34
    Calibration.define_using_ids 38, 25, 28
  end

  def down
    Calibration.where(:insight_id => 38).each do |m|
      m.destroy
    end 
  end
end
