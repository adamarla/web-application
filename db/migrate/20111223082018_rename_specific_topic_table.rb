class RenameSpecificTopicTable < ActiveRecord::Migration
  def change 
    rename_column :specific_topics, :broad_topic_id, :macro_topic_id
    rename_table :specific_topics, :micro_topics
  end 
end
