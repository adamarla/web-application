class EditCalibration8 < ActiveRecord::Migration
  def up
    Calibration.find(8).update_attribute :calculation_id, 34
  end

  def down
    Calibration.find(8).update_attribute :calculation_id, 27
  end
end
