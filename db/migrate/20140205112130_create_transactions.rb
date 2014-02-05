class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :account
      t.integer :quantity
      t.integer :rate_code_id
      t.integer :reference_id
      t.string :reference_type, limit: 20
      t.string :memo

      t.timestamps
    end
    add_index :transactions, :account_id
  end
end
