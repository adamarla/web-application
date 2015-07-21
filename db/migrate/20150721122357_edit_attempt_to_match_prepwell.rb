class EditAttemptToMatchPrepwell < ActiveRecord::Migration
  def change 
    rename_column :attempts, :num_wrong, :num_attempts
    rename_column :attempts, :seen_options, :checked_answer 
    add_column :attempts, :total_time, :integer 
    add_column :attempts, :seen_summary, :boolean, default: false 
  end 
end
