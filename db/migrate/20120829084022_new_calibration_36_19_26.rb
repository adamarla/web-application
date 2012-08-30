class NewCalibration361926 < ActiveRecord::Migration
  def up
    Calibration.define_using_ids 36,19,26
  end

  def down
    Calibration.last.destroy
  end
end
