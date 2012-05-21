class ChangeUrlToText < ActiveRecord::Migration
  def up
    change_table :videos do |t|
      t.change :url, :text
    end
  end

  def down
    change_table :videos do |t|
      t.change :url, :string
    end
  end
end
