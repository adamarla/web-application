class RemoveTexFromRemarks < ActiveRecord::Migration
  def up
    remove_column :remarks, :tex
  end

  def down
    add_column :remarks, :tex, :text
  end
end
