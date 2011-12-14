class RecreateSyllabiTable < ActiveRecord::Migration
  def change 
    create_table :syllabi do |t| 
       t.integer :course_id 
	   t.integer :topic_id 

	   t.timestamps
	end 
  end 
end
