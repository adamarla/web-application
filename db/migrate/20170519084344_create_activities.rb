class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :user_id
      t.integer :sku_id
      t.integer :got_right
      t.integer :date
      t.integer :num_attempts

      t.timestamps
    end
  end
end
