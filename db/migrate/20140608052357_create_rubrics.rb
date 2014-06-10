class CreateRubrics < ActiveRecord::Migration
  def change
    create_table :rubrics do |t|
      t.string :name, limit: 100
      t.integer :account_id
      t.boolean :standard, default: true

      t.timestamps
    end
  end
end
