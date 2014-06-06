class AddLoginAllowedToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :login_allowed, :boolean
  end
end
