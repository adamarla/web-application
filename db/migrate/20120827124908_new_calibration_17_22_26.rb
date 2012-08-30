class NewCalibration172226 < ActiveRecord::Migration
  def up
    Calibration.define_using_ids 17,22,26
  end

  def down
    Calibration.last.destroy
  end
end
