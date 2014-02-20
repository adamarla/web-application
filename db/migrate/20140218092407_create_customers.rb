class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.references :account
      t.integer :credit_balance
      t.integer :cash_balance
      t.string :currency, :limit => 3

      t.timestamps
    end
    add_index :customers, :account_id
  end
end
