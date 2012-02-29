class RenameMicroTopicToTopic < ActiveRecord::Migration
  def change
    rename_table :micro_topics, :topics
  end
end
