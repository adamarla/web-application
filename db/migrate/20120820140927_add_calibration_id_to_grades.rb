class AddCalibrationIdToGrades < ActiveRecord::Migration
  def change
    add_column :grades, :calibration_id, :integer
  end
end
