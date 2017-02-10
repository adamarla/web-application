class AddOpenToParcels < ActiveRecord::Migration
  def change
    add_column :parcels, :open, :boolean, default: true
  end
end
