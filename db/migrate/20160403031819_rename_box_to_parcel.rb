class RenameBoxToParcel < ActiveRecord::Migration
  def change 
    rename_table :boxes, :parcels 
  end 
end
