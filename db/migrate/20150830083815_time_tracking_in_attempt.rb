class TimeTrackingInAttempt < ActiveRecord::Migration
  def change 
    add_column :attempts, :time_to_answer, :integer 
    add_column :attempts, :time_on_cards, :string, limit: 40 
    add_column :attempts, :time_in_activity, :integer 
  end
end
