class AppVersionAsFloat < ActiveRecord::Migration
  def up
    add_column :users, :version, :float, default: 1 

    # String app-version to float 
    User.all.each do |u| 
      v = u.app_version.nil? ? 1 : u.app_version.to_f 
      u.update_attribute :version, v 
    end 

    remove_column :users, :app_version 
  end

  def down
    add_column :users, :app_version, :string, limit: 10
    
    # Float app-version to float 
    User.all.each do |u|
      u.update_attribute :app_version, u.version.to_s 
    end 

    remove_column :users, :version
  end
end
