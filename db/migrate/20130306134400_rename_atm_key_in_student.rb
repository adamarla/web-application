class RenameAtmKeyInStudent < ActiveRecord::Migration
  def change 
    rename_column :students, :atm_key, :uid
  end 
end
