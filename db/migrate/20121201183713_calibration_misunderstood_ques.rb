class CalibrationMisunderstoodQues < ActiveRecord::Migration
  def up
    Calibration.define_using_ids 45, 19, 26
  end

  def down
  end
end
