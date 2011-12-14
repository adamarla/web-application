class AddBroadTopicIdToSpecificTopic < ActiveRecord::Migration
  def change
    add_column :specific_topics, :broad_topic_id, :integer
  end
end
