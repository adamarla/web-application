class TrackNumInvitesAndAppVersion < ActiveRecord::Migration
  def change 
    add_column :users, :num_invites_sent, :integer, default: 0
    add_column :users, :app_version, :string, limit: 10
  end 
end
