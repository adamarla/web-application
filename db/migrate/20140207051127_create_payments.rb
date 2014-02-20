class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :transaction_id
      t.string :ip_address, :limit => 16
      t.string :first_name, :limit => 30
      t.string :last_name, :limit => 30
      t.string :payment_type, :limit => 30
      t.integer :cash_value
      t.string :currency
      t.integer :credits
      t.boolean :success
      t.string :response_message
      t.string :response_params

      t.timestamps
    end
    add_index :payments, :transaction_id
  end
end
