class RemoveFlagsFromQuestion < ActiveRecord::Migration
  def up 
    remove_column :questions, :flags
  end 

  def down
    add_column :questions, :flags, :integer, :default => 0
  end 
end
