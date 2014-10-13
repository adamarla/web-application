class DropContracts < ActiveRecord::Migration
  def up
    drop_table :contracts 
  end

  def down
  end
end
