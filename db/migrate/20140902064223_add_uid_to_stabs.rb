class AddUidToStabs < ActiveRecord::Migration
  def change
    add_column :stabs, :uid, :integer 
    add_index :stabs, :uid
  end
end
