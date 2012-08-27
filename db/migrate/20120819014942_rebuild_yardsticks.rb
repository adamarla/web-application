class RebuildYardsticks < ActiveRecord::Migration
  def up
    remove_column :yardsticks, :example
    remove_column :yardsticks, :default_allotment
    remove_column :yardsticks, :created_at
    remove_column :yardsticks, :updated_at
    remove_column :yardsticks, :annotation
    remove_column :yardsticks, :colour
    add_column :yardsticks, :insight, :boolean, :default => false
    add_column :yardsticks, :formulation, :boolean, :default => false
    add_column :yardsticks, :calculation, :boolean, :default => false
    add_column :yardsticks, :weight, :integer, :default => 1
    add_column :yardsticks, :bottomline, :string

  end

  def down
    add_column :yardsticks, :example, :string
    add_column :yardsticks, :default_allotment, :integer
    add_column :yardsticks, :annotation, :string
    add_column :yardsticks, :colour, :integer

    change_table :yardsticks do |t|
      t.timestamps
    end

    remove_column :yardsticks, :insight
    remove_column :yardsticks, :formulation
    remove_column :yardsticks, :calculation
    remove_column :yardsticks, :weight

    remove_column :yardsticks, :bottomline
  end

end
