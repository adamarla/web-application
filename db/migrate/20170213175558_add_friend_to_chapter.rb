class AddFriendToChapter < ActiveRecord::Migration
  def change
    add_column :chapters, :friend_id, :integer, default: 0
  end
end
