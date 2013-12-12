class AddPageBreaksToQSelection < ActiveRecord::Migration
  def change
    add_column :q_selections, :page_breaks, :string, limit: 10
  end
end
