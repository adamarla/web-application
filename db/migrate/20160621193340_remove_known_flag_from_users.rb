class RemoveKnownFlagFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :known_associate
  end

  def down
    add_column :users, :known_associate, :boolean, default: false 
  end
end
