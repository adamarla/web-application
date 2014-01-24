class CreateApprenticeships < ActiveRecord::Migration
  def change
    create_table :apprenticeships do |t|
      t.integer :examiner_id
      t.integer :teacher_id

      t.timestamps
    end
    add_index :apprenticeships, :examiner_id
    add_index :apprenticeships, :teacher_id
  end
end
