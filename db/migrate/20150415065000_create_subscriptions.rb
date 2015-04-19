class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :student_id
      t.integer :package_id

      t.timestamps
    end
  end
end
