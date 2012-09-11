class NewCalibration382026 < ActiveRecord::Migration
  def up
    Calibration.define_using_ids 38,20,26
    Calibration.last.update_attribute :allotment, 0
  end

  def down
  end
end
