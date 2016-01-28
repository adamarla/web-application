class AddKnownAssociateToPupils < ActiveRecord::Migration
  def change
    add_column :pupils, :known_associate, :boolean, :default => false
  end
end
