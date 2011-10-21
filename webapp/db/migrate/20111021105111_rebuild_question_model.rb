class RebuildQuestionModel < ActiveRecord::Migration
  def up 
    change_table :questions do |t| 
	  t.remove :folder
	  t.boolean :favourite, :default => false 
	  t.references :db_question, :teacher
	  t.integer :times_used, :default => 0
	end 
  end 

  def down 
    change_table :questions do |t| 
	  t.string :folder 
	  t.remove :favourite, :times_used 
	  t.remove :db_question_id, :teacher_id
	end 
  end 
end
