class DefineNewCalibrations < ActiveRecord::Migration
  def up
    # non-mcq / subjective calibrations 
    Calibration.build_viable_calibrations

    # mcq calibrations 
    Yardstick.mcqs.each do |m|
      v = Calibration.fair_value_for m
      c = Calibration.new :mcq_id => m.id, :allotment => v
      c.save
    end 
  end

  def down
    Calibration.all.each do |m| 
      m.destroy
    end 
  end
end
