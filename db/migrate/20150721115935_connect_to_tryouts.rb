class ConnectToTryouts < ActiveRecord::Migration
  def change 
    rename_column :disputes, :attempt_id, :tryout_id
    rename_column :doodles, :attempt_id, :tryout_id
    rename_column :remarks, :attempt_id, :tryout_id
  end 
end
