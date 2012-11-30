class NewCalibrationReverseEngg < ActiveRecord::Migration
  def up
    Calibration.define_using_ids 42,43,26
  end

  def down
  end
end
