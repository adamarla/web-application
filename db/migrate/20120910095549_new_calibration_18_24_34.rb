class NewCalibration182434 < ActiveRecord::Migration
  def up
    Calibration.define_using_ids 18,24,34
  end

  def down
    c = Calibration.where(:insight_id => 18, :formulation_id => 24, :calculation_id => 34).first
    c.destroy unless c.nil?
  end
end
