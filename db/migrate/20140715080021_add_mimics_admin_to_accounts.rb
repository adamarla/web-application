class AddMimicsAdminToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :mimics_admin, :boolean, default: false
  end
end
