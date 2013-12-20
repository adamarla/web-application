class CreateDrafts < ActiveRecord::Migration
  def change
    create_table :drafts do |t|
      t.string :layout
      t.integer :quiz_id
      t.integer :index
    end
    add_index :drafts, :quiz_id
  end
end
