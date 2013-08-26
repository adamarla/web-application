class PolymorphicInterfaceInVideos < ActiveRecord::Migration
  def change
    add_column :videos, :watchable_id, :integer
    add_column :videos, :watchable_type, :string, limit: 20
  end
end
