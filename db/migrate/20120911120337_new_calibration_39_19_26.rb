class NewCalibration391926 < ActiveRecord::Migration
  def up
    Calibration.define_using_ids 39, 19,26
  end

  def down
    Calibration.where(:insight_id => 39).each do |m|
      m.destroy
    end
  end
end
