class AddGradeLevelNumStudentsToContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :grade_level, :integer
    add_column :contracts, :num_students, :integer
  end
end
