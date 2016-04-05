class JustEmptyFlagInSku < ActiveRecord::Migration
  def up
		remove_column :skus, :tags_changed 
		remove_column :skus, :svgs_changed 
		add_column :skus, :virgin, :boolean, default: true 
  end

  def down
		add_column :skus, :tags_changed, :boolean, default: false 
		add_column :skus, :svgs_changed, :boolean, default: false 
		remove_column :skus, :virgin
  end
end
