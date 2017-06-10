class AddIndexToActivity < ActiveRecord::Migration
  def change
    add_index :activities, :user_id
    add_index :activities, :date
  end
end
