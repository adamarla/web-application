class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :accounting_doc_id
      t.integer :account_id
      t.integer :quantity
      t.integer :rate_code_id
      t.integer :reference_id
      t.integer :reference_type

      t.timestamps
    end
    add_index :transactions, :accounting_doc_id
    add_index :transactions, :reference_id
  end
end
