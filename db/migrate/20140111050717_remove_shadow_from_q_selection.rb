class RemoveShadowFromQSelection < ActiveRecord::Migration
  def up
    remove_column :q_selections, :shadow
  end

  def down
    add_column :q_selections, :shadow, :integer
  end
end
