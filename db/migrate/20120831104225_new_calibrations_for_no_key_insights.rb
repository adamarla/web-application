class NewCalibrationsForNoKeyInsights < ActiveRecord::Migration
  def up
    Calibration.define_using_ids 37,20,26 
    Calibration.define_using_ids 37,21,26 
  end

  def down
    Calibration.where(:insight_id => 37).each do |m|
      m.destroy
    end
  end
end
