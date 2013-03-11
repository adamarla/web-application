class DropBoards < ActiveRecord::Migration
  def up
    drop_table :boards
  end

  def down
    create_table :boards do |t|
      t.string :name
      t.integer :id
    end
  end
end
