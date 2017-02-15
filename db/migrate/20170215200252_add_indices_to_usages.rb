class AddIndicesToUsages < ActiveRecord::Migration
  def change
    add_index :usages, :user_id
    add_index :usages, :date
  end
end
