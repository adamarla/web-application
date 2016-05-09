class ChangePupilToUser < ActiveRecord::Migration
  def change 
    rename_table :pupils, :users

    rename_column :expertise, :pupil_id, :user_id 
    rename_column :devices, :pupil_id, :user_id 
    rename_column :attempts, :pupil_id, :user_id 
    rename_column :daily_streaks, :pupil_id, :user_id 
  end 
end
