class NewCalibration172334 < ActiveRecord::Migration
  def up
    Calibration.define_using_ids 17,23,34 
  end

  def down
    c = Calibration.where(:insight_id => 17, :formulation_id => 23, :calculation_id => 34).first
    c.destroy unless c.nil?
  end
end
