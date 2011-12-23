class RenameSpecificTopicFkInSyllabus < ActiveRecord::Migration
  def change 
    rename_column :syllabi, :specific_topic_id, :micro_topic_id
  end 
end
