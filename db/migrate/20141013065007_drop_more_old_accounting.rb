class DropMoreOldAccounting < ActiveRecord::Migration
  def up
    drop_table :payments 
    drop_table :rate_codes 
    drop_table :cost_codes
  end

  def down
  end
end
