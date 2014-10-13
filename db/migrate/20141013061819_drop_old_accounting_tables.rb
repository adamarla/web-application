class DropOldAccountingTables < ActiveRecord::Migration
  def up
    drop_table :transactions 
    drop_table :accounting_docs 
    drop_table :customers
  end

  def down
  end
end
