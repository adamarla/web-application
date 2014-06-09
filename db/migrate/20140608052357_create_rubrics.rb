class CreateRubrics < ActiveRecord::Migration
  def change
    create_table :rubrics do |t|
      t.string :name, limit: 100
      t.integer :teacher_id

      t.timestamps
    end
  end
end
