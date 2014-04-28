class CreateDisputes < ActiveRecord::Migration
  def change
    create_table :disputes do |t|
      t.integer :student_id 
      t.integer :graded_response_id 
      t.text :text 
      t.timestamps
    end
    add_index :disputes, :student_id
  end
end
