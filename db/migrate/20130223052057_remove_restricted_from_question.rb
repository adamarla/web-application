class RemoveRestrictedFromQuestion < ActiveRecord::Migration
  def up
    remove_column :questions, :restricted
  end

  def down
    add_column :questions, :restricted, :boolean, :default => true
  end
end
