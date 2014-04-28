class CreateAccountingDocs < ActiveRecord::Migration
  def change
    create_table :accounting_docs do |t|
      t.integer :doc_type
      t.references :customer
      t.date :doc_date
      t.boolean :open, :default => true

      t.timestamps
    end
    add_index :accounting_docs, :customer_id
  end
end
