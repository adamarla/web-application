class RemoveCalibration < ActiveRecord::Migration
  def up
    drop_table :calibrations
    remove_column :graded_responses, :calibration_id
  end

  def down
    # irreversible migration
  end
end
