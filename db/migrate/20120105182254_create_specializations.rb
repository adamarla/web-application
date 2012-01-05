class CreateSpecializations < ActiveRecord::Migration
  def change
    create_table :specializations do |t|
      t.integer :teacher_id
      t.integer :subject_id

      t.timestamps
    end
  end
end
