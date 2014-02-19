class CreateDoodles < ActiveRecord::Migration
  def change
    create_table :doodles do |t|
      t.integer :examiner_id
      t.integer :feedback, default: 0

      t.timestamps
    end

    add_index :doodles, :examiner_id
  end
end
