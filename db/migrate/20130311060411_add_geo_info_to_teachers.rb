class AddGeoInfoToTeachers < ActiveRecord::Migration
  def change
    add_column :teachers, :country_id, :integer 
    add_column :teachers, :zip_code, :string, :limit => 10
  end
end
