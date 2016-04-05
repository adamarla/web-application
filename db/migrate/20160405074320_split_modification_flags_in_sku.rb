class SplitModificationFlagsInSku < ActiveRecord::Migration
	def change 
		rename_column :skus, :modified, :tags_changed
		add_column :skus, :svgs_changed, :boolean, default: false
	end 
end
