class ChangesForSublimeVideo < ActiveRecord::Migration
  def up
    change_table :videos do |t| 
      t.remove :html
      t.string :sublime_uid, limit: 20
      t.string :sublime_title, limit: 70
    end
  end

  def down
    change_table :videos do |t| 
      t.text :html 
      t.remove :sublime_uid
      t.remove :sublime_title
    end
  end
end
