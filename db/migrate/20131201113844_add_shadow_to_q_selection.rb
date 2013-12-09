class AddShadowToQSelection < ActiveRecord::Migration
  def change
    add_column :q_selections, :shadow, :integer
  end
end
