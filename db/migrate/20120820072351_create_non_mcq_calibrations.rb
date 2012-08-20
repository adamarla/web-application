class CreateNonMcqCalibrations < ActiveRecord::Migration
  def up
    Calibration.build_viable_calibrations
  end

  def down
    Calibration.where(:mcq_id => nil).each do |m|
      m.destroy
    end 
  end
end
