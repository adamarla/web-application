class AddDeviseColumnsToAccount < ActiveRecord::Migration

  def change
    change_table :accounts do |a|
      a.string :authentication_token
    end
    add_index :accounts, :authentication_token
  end

end
