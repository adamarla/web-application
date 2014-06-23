class DropRequirementTable < ActiveRecord::Migration
  def up
    drop_table :requirements 
  end

  def down
  end
end
