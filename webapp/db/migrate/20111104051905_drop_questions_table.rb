class DropQuestionsTable < ActiveRecord::Migration
  def up
    drop_table :questions
  end

  def down
    create_table :questions do |t| 
	  t.integer :db_question_id  
	  t.boolean :favourite, :default => false
	  t.integer :teacher_id 
	  t.integer :times_used 
	  t.integer :quiz_id

	  t.timestamps
	end 
  end
end
