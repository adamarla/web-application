class DropSyllabi < ActiveRecord::Migration
  def up
    drop_table :syllabi
  end

  def down
    create_table :syllabi do |t|
      t.integer :course_id
      t.integer :topic_id
    end
  end
end
