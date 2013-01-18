class AddInboxedToTestpaper < ActiveRecord::Migration
  def change
    add_column :testpapers, :inboxed, :boolean, :default => false
  end
end
