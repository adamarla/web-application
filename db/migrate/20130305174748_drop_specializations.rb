class DropSpecializations < ActiveRecord::Migration
  def up
    drop_table :specializations
  end

  def down
    create_table :specializations do |t|
      t.integer :teacher_id
      t.integer :subject_id
      t.integer :klass
    end
  end
end
