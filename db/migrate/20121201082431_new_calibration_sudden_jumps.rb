class NewCalibrationSuddenJumps < ActiveRecord::Migration
  def up
    Calibration.define_using_ids 18,44,26
    Calibration.define_using_ids 38,44,26
  end

  def down
  end
end
