class AddAutoDownloadToBundle < ActiveRecord::Migration
  def change
    add_column :bundles, :auto_download, :boolean, default: false
  end
end
