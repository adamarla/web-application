class RemoveTitleFromVideos < ActiveRecord::Migration
  def up
    remove_column :videos, :title
  end

  def down
    add_column :videos, :title, :string, limit: 70
  end
end
