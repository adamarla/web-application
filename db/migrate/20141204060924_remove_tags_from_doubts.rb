class RemoveTagsFromDoubts < ActiveRecord::Migration
  def up
    remove_column :doubts, :tags
  end

  def down
    add_column :doubts, :tags, :string
  end
end
