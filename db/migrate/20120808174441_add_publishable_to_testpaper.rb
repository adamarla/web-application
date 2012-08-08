class AddPublishableToTestpaper < ActiveRecord::Migration
  def change
    add_column :testpapers, :publishable, :boolean, :default => false
  end
end
