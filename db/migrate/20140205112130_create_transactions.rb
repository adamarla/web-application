class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :customer
      t.integer :account_id
      t.integer :quantity
      t.integer :rate_code_id
      t.integer :reference_id
      t.integer :reference_type
      t.string :memo

      t.timestamps
    end
    add_index :transactions, :customer_id
  end
end
