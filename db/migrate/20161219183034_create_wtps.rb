class CreateWtps < ActiveRecord::Migration
  def change
    create_table :wtps do |t|
      t.integer :user_id
      t.integer :price_per_week
      t.boolean :agreed, default: false
      t.integer :num_refusals, default: 0
      t.integer :first_asked_on, default: 0
      t.integer :agreed_on, default: 0
    end
  end
end
