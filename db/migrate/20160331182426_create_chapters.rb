class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|
      t.string :name, limit: 70 
      t.integer :level_id
      t.integer :subject_id
    end

    add_index :chapters, :level_id 
    add_index :chapters, :subject_id

  end # of change
end
