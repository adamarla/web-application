class MoveAllGeoInfoToAccount < ActiveRecord::Migration
  def up
    add_column :accounts, :state, :string, :limit => 40
    add_column :accounts, :city, :string, :limit => 40
    add_column :accounts, :zip_code, :string, :limit => 10
    remove_column :teachers, :zip_code
  end

  def down
    remove_column :accounts, :state
    remove_column :accounts, :city
    remove_column :accounts, :zip_code
    add_column :teachers, :zip_code, :string, :limit => 10
  end
end
