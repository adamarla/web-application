class CreateExaminers < ActiveRecord::Migration
  def change
    create_table :examiners do |t|
      t.integer :num_contested, :default => 0

      t.timestamps
    end
  end
end
