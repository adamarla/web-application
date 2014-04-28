class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :invoice
      t.string :ip_address, :limit => 16
      t.string :name, :limit => 60
      t.string :source, :limit => 30
      t.integer :cash_value
      t.string :currency, :limit => 3
      t.integer :credits
      t.boolean :success
      t.string :response_message
      t.text :response_params

      t.timestamps
    end
  end
end
