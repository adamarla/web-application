class CreateBehaviours < ActiveRecord::Migration
  def change
    create_table :behaviours do |t|
      t.integer :student_id
      t.integer :n_stabs, default: 0
      t.integer :n_reccos, default: 0 
      t.integer :n_puzzles, default: 0
    end
  end
end
