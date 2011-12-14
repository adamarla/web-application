class RenameTopicToSpecificTopic < ActiveRecord::Migration
  def change 
    rename_table :topics, :specific_topics
  end 
end
