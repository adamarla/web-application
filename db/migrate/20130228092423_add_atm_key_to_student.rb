class AddAtmKeyToStudent < ActiveRecord::Migration
  def change
    add_column :students, :atm_key, :string, :limit => 20
  end
end
