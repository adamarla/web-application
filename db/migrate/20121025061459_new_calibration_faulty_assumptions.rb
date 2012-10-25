class NewCalibrationFaultyAssumptions < ActiveRecord::Migration
  def up
    Calibration.define_using_ids 40,19,26 
  end

  def down
    Calibration.where(:enabled => true).last.destroy
  end
end
