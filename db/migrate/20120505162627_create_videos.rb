class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :url
      t.boolean :restricted, :default => true
      t.boolean :instructional, :default => false

      t.timestamps
    end
  end
end
