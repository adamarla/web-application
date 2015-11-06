class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :uid, limit: 40
      t.integer :question_id
      t.integer :num_received, default: 0 
      t.integer :num_opened, default: 0
    end
  end
end
