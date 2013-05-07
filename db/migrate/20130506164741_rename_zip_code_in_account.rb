class RenameZipCodeInAccount < ActiveRecord::Migration
  def change 
    rename_column :accounts, :zip_code, :postal_code
  end
end
