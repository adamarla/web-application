class LengthenZipParcelUids < ActiveRecord::Migration
  def up
    change_column :parcels, :name, :string, limit: 50
    change_column :zips, :name, :string, limit: 50
  end

  def down
    change_column :parcels, :name, :string, limit: 30
    change_column :zips, :name, :string, limit: 30
  end
end
