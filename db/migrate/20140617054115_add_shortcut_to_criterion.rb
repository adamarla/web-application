class AddShortcutToCriterion < ActiveRecord::Migration
  def change
    add_column :criteria, :shortcut, :string, limit: 1
  end
end
