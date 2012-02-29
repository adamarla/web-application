class RenameMacroTopicFk < ActiveRecord::Migration
  def change 
    rename_column :micro_topics, :macro_topic_id, :vertical_id
  end 
end
