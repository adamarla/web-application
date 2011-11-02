class CreateSyllabi < ActiveRecord::Migration
  def change
    create_table :syllabi do |t|
      t.string :name
      t.integer :board_id
      t.integer :grade
      t.integer :subject

      t.timestamps
    end
  end
end
