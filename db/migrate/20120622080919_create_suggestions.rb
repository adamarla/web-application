class CreateSuggestions < ActiveRecord::Migration
  def change
    create_table :suggestions do |t|
      t.integer :teacher_id
      t.integer :examiner_id
      t.boolean :completed

      t.timestamps
    end
  end
end
