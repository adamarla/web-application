class RenameDailyStreakToUsage < ActiveRecord::Migration
  def change 
    rename_table :daily_streaks, :usages 
    add_column :usages, :time_zone, :string, limit: 50 
    add_column :usages, :time_on_snippets, :integer, default: 0  
    add_column :usages, :time_on_questions, :integer, default: 0 
    add_column :usages, :num_snippets_done, :integer, default: 0  
    add_column :usages, :num_questions_done, :integer, default: 0
  end 
end
