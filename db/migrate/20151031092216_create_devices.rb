class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.integer :pupil_id
      t.string :gcm_token
      t.timestamps
    end
    add_index :devices, :pupil_id
  end
end
