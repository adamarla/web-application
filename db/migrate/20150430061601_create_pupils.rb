class CreatePupils < ActiveRecord::Migration
  def change
    create_table :pupils do |t|
      t.string :first_name, limit: 50
      t.string :last_name, limit: 50
      t.string :email, limit: 100
      t.integer :gender 
      t.string :birthday, limit: 50

      t.timestamps
    end
    add_index :pupils, :email
  end
end
