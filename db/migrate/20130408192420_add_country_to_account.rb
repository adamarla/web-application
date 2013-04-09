class AddCountryToAccount < ActiveRecord::Migration
  def up
    add_column :accounts, :country, :integer, :default => 100 # default country = India
    remove_column :accounts, :trial
  end

  def down
    add_column :accounts, :trial, :boolean, :default => true
    remove_column :accounts, :country
  end
end
