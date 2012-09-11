class RecalibrateFormulationHeavyCalibrations < ActiveRecord::Migration
  def up
    Calibration.find(30).update_attribute :allotment, 0
    Calibration.find(31).update_attribute :allotment, 40
    Calibration.find(32).update_attribute :allotment, 50
    Calibration.find(33).update_attribute :allotment, 60
    Calibration.find(34).update_attribute :allotment, 65
    Calibration.find(35).update_attribute :allotment, 85
    Calibration.find(36).update_attribute :allotment, 90
    Calibration.find(37).update_attribute :allotment, 100
    Calibration.find(38).update_attribute :allotment, 85
    Calibration.find(39).update_attribute :allotment, 90
    Calibration.find(40).update_attribute :allotment, 100
  end

  def down
  end
end
