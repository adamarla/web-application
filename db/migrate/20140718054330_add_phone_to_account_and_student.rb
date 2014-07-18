class AddPhoneToAccountAndStudent < ActiveRecord::Migration
  def change
    add_column :students, :phone, :string, limit: 15
    add_column :accounts, :phone, :string, limit: 15
  end
end
