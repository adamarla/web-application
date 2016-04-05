class AddModifiedToZips < ActiveRecord::Migration
  def change
		add_column :zips, :modified, :boolean, default: false 
  end
end
