class TrackVideoType < ActiveRecord::Migration
  def up
    change_table :videos do |t|
      t.remove :instructional
      t.rename :restricted, :tutorial
      t.boolean :history, default: false
      t.boolean :lecture, default: false
    end
  end

  def down
    change_table :videos do |t|
      t.remove :lecture
      t.remove :history
      t.rename :tutorial, :restricted
      t.boolean :instructional, default: false
    end
  end
end
