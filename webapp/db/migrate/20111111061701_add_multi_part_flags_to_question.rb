class AddMultiPartFlagsToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :multi_part, :boolean, :default => false
    add_column :questions, :num_parts, :integer
  end
end
