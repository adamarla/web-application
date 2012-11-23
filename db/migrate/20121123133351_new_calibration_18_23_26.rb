class NewCalibration182326 < ActiveRecord::Migration
  def up
    Calibration.define_using_ids 18,23,26 
  end

  def down
    c = Calibration.where(:insight_id => 18, :formulation_id => 23, :calculation_id => 26).first
    c.destroy unless c.nil?
  end
end
