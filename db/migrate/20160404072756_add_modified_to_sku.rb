class AddModifiedToSku < ActiveRecord::Migration
  def change
    add_column :skus, :modified, :boolean, default: false 
  end
end
