class RenameBroadTopicTable < ActiveRecord::Migration
  def change 
    rename_table :broad_topics, :macro_topics
  end 
end
