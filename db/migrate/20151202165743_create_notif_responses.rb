class CreateNotifResponses < ActiveRecord::Migration
  def change
    create_table :notif_responses do |t|
      t.string :category, limit: 10
      t.string :uid, limit: 20 
      t.integer :parent_id 
      t.integer :num_sent, default: 0
      t.integer :num_received, default: 0 
      t.integer :num_failed, default: 0 
      t.integer :num_dismissed, default: 0 
      t.integer :num_opened, default: 0
    end
  end
end
