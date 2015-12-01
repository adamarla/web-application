class CreateJotd < ActiveRecord::Migration
  def change
    create_table :jotd do |t|
      t.integer :uid, limit: 20
      t.integer :joke_id 
      t.integer :num_sent 
      t.integer :num_failed 
      t.integer :num_received 
      t.integer :num_opened
      t.integer :num_dismissed 
    end
  end
end
