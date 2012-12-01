class NewCalibration182226 < ActiveRecord::Migration
  def up
    Calibration.define_using_ids 18,22,26
  end

  def down
  end
end
