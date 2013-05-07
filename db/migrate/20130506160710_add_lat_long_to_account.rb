class AddLatLongToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :latitude, :float
    add_column :accounts, :longitude, :float
  end
end
