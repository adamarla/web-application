class AddAutoRenewImmediateToSektion < ActiveRecord::Migration
  def change
    add_column :sektions, :auto_renew_immediate, :boolean, default: false
  end
end
