class CreateQSelections < ActiveRecord::Migration
  def change
    create_table :q_selections do |t|
      t.integer :quiz_id
      t.integer :question_id
      t.integer :page

      t.timestamps
    end
  end
end
