class CreateChecklists < ActiveRecord::Migration
  def change
    create_table :checklists do |t|
      t.integer :rubric_id
      t.integer :criterion_id
      t.integer :index 
    end
  end
end
