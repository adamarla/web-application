class RenameGradedResponseTable < ActiveRecord::Migration
  def change 
    rename_table :graded_responses, :attempts
    rename_column :doodles, :graded_response_id, :attempt_id 
    rename_column :disputes, :graded_response_id, :attempt_id 
    rename_column :remarks, :graded_response_id, :attempt_id 
  end 
end
