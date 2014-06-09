class CreateCriteria < ActiveRecord::Migration
  def change
    create_table :criteria do |t|
      t.string :text 
      t.integer :penalty, default: 0
      t.integer :account_id
      t.boolean :standard, default: true

      t.timestamps
    end
    add_index :criteria, :account_id
  end
end
