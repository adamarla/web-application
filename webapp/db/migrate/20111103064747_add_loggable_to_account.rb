class AddLoggableToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :loggable_id, :integer
    add_column :accounts, :loggable_type, :string
  end
end
