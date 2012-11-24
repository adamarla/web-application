class NewCalibrationHonestErrors < ActiveRecord::Migration
  def up
    Calibration.define_using_ids 17,41,26
    Calibration.define_using_ids 17,41,34
    Calibration.define_using_ids 18,41,26
    Calibration.define_using_ids 18,41,27
    Calibration.define_using_ids 18,41,34
    Calibration.define_using_ids 38,41,27
    Calibration.define_using_ids 38,41,34
  end

  def down
  end
end
