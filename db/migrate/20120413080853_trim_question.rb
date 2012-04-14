class TrimQuestion < ActiveRecord::Migration
  def up
    remove_column :questions, :mcq
    remove_column :questions, :multi_correct
    remove_column :questions, :half_page
    remove_column :questions, :full_page
    remove_column :questions, :num_parts
    remove_column :questions, :multi_part
  end

  def down
    add_column :questions, :mcq, :boolean, :default => false
    add_column :questions, :multi_correct, :boolean, :default => false
    add_column :questions, :half_page, :boolean, :default => false
    add_column :questions, :full_page, :boolean, :default => true
    add_column :questions, :multi_part, :boolean, :default => false
    add_column :questions, :num_parts, :integer
  end
end
