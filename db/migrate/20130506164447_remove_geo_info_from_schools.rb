class RemoveGeoInfoFromSchools < ActiveRecord::Migration
  def up
    remove_column :schools, :zip_code
    remove_column :schools, :country_id
  end

  def down
    add_column :schools, :zip_code, :string, :limit => 10
    add_column :schools, :country_id, :integer
  end
end
