class CreateWtps < ActiveRecord::Migration
  def change
    create_table :wtps do |t|
      t.integer :user_id
      t.integer :price
      t.boolean :agreed, default: false
      t.integer :num_refusals, default: 0
      t.integer :first_asked_on
      t.integer :agreed_on
    end
  end
end
