class TrimVideoModel < ActiveRecord::Migration
  def up
    change_table :videos do |t|
      t.remove :index
      t.remove :tutorial
      t.remove :title
      t.remove :lecture
      t.remove :history
      t.remove :description
    end
  end

  def down
    change_table :videos do |t|
      t.integer :index, default: -1
      t.boolean :tutorial, default: true
      t.boolean :lecture, default: false
      t.boolean :history, default: false
      t.string :title, limit: 70
      t.text :description
    end
  end
end
