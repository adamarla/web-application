class ChangeAllotmentTypeToFloat < ActiveRecord::Migration
  def up
    change_column :grades, :allotment, :float
    change_column :calibrations, :allotment, :float
  end

  def down
    change_column :grades, :allotment, :integer
    change_column :calibrations, :allotment, :integer
  end
end
