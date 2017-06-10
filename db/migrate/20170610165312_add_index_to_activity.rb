class AddIndexToActivity < ActiveRecord::Migration
  def change
    add_index :activity, :user_id
    add_index :activity, :date
  end
end
