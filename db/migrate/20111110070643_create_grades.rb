class CreateGrades < ActiveRecord::Migration
  def change
    create_table :grades do |t|
      t.integer :allotment
      t.integer :grade_description_id
      t.integer :teacher_id

      t.timestamps
    end
  end
end
