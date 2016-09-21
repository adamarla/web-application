class TrackFbLogin < ActiveRecord::Migration
  def change 
    add_column :users, :facebook_login, :boolean, default: false 
  end 
end
