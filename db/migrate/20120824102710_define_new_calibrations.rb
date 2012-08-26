class DefineNewCalibrations < ActiveRecord::Migration
  def up
    # non-mcq / subjective calibrations 
    Calibration.build_viable_calibrations

    # mcq calibrations based on 'new' yardsticks only. The old ones have 
    # IDs < 13
    Yardstick.mcqs.where('id > ?', 13).each do |m|
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
