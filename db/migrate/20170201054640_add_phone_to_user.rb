class AddPhoneToUser < ActiveRecord::Migration
  def change
    add_column :users, :phone, :string, limit: 20 
  end
end
