class NewCalibrationsSillyMistakes < ActiveRecord::Migration
  def up
    Calibration.define_using_ids 17,35,26
    Calibration.define_using_ids 18,35,26
  end

  def down
    Calibration.last(2).each do |m|
      m.destroy
    end 
  end
end
