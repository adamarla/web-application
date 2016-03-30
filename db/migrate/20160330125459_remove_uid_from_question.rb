class RemoveUidFromQuestion < ActiveRecord::Migration
  def up
    remove_column :questions, :uid
  end

  def down
    add_column :questions, :uid, :string, limit: 20 
  end
end
