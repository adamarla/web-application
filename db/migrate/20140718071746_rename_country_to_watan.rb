class RenameCountryToWatan < ActiveRecord::Migration
  def change 
    rename_table :countries, :watan
  end 
end
