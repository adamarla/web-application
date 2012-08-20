class CreateCalibrationsForMcqs < ActiveRecord::Migration
  def up
    Yardstick.mcqs.each do |m|
      c = Calibration.new :mcq_id => m.id, :allotment => 50
      c.save
    end 
  end

  def down
    Calibration.where("mcq_id IS NOT ?", nil).each do |m| 
      m.destroy
    end 
  end
end
