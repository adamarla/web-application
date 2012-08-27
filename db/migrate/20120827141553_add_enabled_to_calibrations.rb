class AddEnabledToCalibrations < ActiveRecord::Migration
  def change
    add_column :calibrations, :enabled, :boolean, :default => true
  end
end
