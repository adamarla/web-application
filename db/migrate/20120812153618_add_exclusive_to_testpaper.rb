class AddExclusiveToTestpaper < ActiveRecord::Migration
  def change
    add_column :testpapers, :exclusive, :boolean, :default => true
  end
end
