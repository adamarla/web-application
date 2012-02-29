class RenameMicroTopicFk < ActiveRecord::Migration
  def change 
    rename_column :questions, :micro_topic_id, :topic_id
    rename_column :syllabi, :micro_topic_id, :topic_id
  end 
end
