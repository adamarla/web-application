class CreateBroadTopics < ActiveRecord::Migration
  def change
    create_table :broad_topics do |t|
      t.string :name

      t.timestamps
    end
  end
end
