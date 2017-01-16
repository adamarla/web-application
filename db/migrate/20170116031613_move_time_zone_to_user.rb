class MoveTimeZoneToUser < ActiveRecord::Migration
  def up
    add_column :users, :time_zone, :string, limit: 50 

    # Usage.time_zone -> User.time_zone 
    uids = Usage.all.map(&:user_id).uniq
    User.where(id: uids).each do |user| 
      tz = Usage.where(user_id: user.id).map(&:time_zone).uniq.first 
      user.update_attribute :time_zone, tz
    end 

    remove_column :usages, :time_zone
  end

  def down
    add_column :usages, :time_zone, :string, limit: 50 

    # User.time_zone -> Usage.time_zone 
    uids = Usage.all.map(&:user_id).uniq
    User.where(id: uids).each do |user| 
      tz = user.time_zone 
      Usage.where(user_id: user.id).each do |u| 
        u.update_attribute :time_zone, tz
      end 
    end 

    remove_column :users, :time_zone 
  end
end
