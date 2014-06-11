class CreateChecklists < ActiveRecord::Migration
  def change
    create_table :checklists do |t|
      t.integer :rubric_id
      t.integer :criterion_id
      t.integer :index 
      t.boolean :active, default: false 
    end
    add_index :checklists, :rubric_id 
    add_index :checklists, :criterion_id 
  end
end
