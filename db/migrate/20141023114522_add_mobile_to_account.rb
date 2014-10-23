class AddMobileToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :mobile, :string
  end
end
