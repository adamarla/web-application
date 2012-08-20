class RemoveExampleFromCalibrations < ActiveRecord::Migration
  def up
    remove_column :calibrations, :example
  end

  def down
    add_column :calibrations, :example, :string
  end
end
