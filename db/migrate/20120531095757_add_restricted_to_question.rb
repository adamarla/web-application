class AddRestrictedToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :restricted, :boolean, :default => true
  end
end
