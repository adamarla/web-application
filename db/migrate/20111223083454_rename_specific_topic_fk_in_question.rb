class RenameSpecificTopicFkInQuestion < ActiveRecord::Migration
  def change 
    rename_column :questions, :specific_topic_id, :micro_topic_id
  end 
end
