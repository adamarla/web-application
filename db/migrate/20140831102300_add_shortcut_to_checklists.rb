class AddShortcutToChecklists < ActiveRecord::Migration
  def up
    add_column :checklists, :shortcut, :string, limit: 1
    remove_column :criteria, :shortcut 
  end 

  def down
    add_column :criteria, :shortcut, :string, limit: 1
    remove_column :checklists, :shortcut
  end
end
