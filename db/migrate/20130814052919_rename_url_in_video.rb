class RenameUrlInVideo < ActiveRecord::Migration
  def change
    rename_column :videos, :url, :html
  end
end
