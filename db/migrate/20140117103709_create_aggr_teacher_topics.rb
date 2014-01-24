class CreateAggrTeacherTopics < ActiveRecord::Migration
  def change
    create_table :aggr_teacher_topics do |t|
      t.integer :teacher_id
      t.integer :topic_id
      t.float   :benchmark
      t.float   :average_score
      t.integer :basis_attempts

      t.timestamps
    end
  end
end
