class RemoveCompiledFromWorksheet < ActiveRecord::Migration
  def up
    remove_column :worksheets, :compiled
  end

  def down
    add_column :worksheets, :compiled, :boolean, default: false
  end
end
