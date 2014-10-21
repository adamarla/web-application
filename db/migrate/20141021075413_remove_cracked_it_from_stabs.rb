class RemoveCrackedItFromStabs < ActiveRecord::Migration
  def up
    remove_column :stabs, :cracked_it 
  end

  def down
    add_column :stabs, :cracked_it, :boolean 
  end
end
