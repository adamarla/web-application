class RenameTopicFk < ActiveRecord::Migration
  def change 
    rename_column :syllabi, :topic_id, :specific_topic_id
	rename_column :questions, :topic_id, :specific_topic_id
  end 
end
