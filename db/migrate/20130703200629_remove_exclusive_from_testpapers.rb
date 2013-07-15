class RemoveExclusiveFromTestpapers < ActiveRecord::Migration
  def up
    remove_column :testpapers, :exclusive
  end

  def down
    add_column :testpapers, :exclusive, :boolean, :default => true
  end
end
