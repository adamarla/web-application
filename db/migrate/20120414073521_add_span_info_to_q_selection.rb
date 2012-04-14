class AddSpanInfoToQSelection < ActiveRecord::Migration
  def up
    add_column :q_selections, :end, :integer
    rename_column :q_selections, :page, :start

    QSelection.all.each do |m|
      m.update_attribute :end, m.start
    end
  end

  def down
    remove_column :q_selections, :end
    rename_column :q_selections, :start, :page
  end
end
