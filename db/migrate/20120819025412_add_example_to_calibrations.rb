class AddExampleToCalibrations < ActiveRecord::Migration
  def change
    add_column :calibrations, :example, :string
  end
end
