class AddActiveBooleanToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :active, :boolean, :default => true
	Account.reset_column_information
	Account.all.each { |account| account.update_attribute(:active, true) }
  end
end
