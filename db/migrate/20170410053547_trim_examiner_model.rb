class TrimExaminerModel < ActiveRecord::Migration
  def up
    change_table :examiners do |t| 
      t.remove :last_workset_on 
      t.remove :n_assigned 
      t.remove :n_graded 
      t.remove :mentor_id 
      t.remove :mentor_is_teacher
      t.remove :internal
    end 
  end

  def down
    change_table :examiners do |t| 
      t.datetime :last_workset_on 
      t.integer :n_assigned, default: 0
      t.integer :n_graded, default: 0
      t.integer :mentor_id 
      t.boolean :mentor_is_teacher, default: false 
      t.boolean :internal, default: false 
    end 
  end
end
