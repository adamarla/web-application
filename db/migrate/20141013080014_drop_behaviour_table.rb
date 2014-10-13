class DropBehaviourTable < ActiveRecord::Migration
  def up
    drop_table :behaviours 
  end

  def down
  end
end
