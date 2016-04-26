class AddMaxZipSizeToParcel < ActiveRecord::Migration
  def change
    add_column :parcels, :max_zip_size, :integer, default: -1
  end
end
