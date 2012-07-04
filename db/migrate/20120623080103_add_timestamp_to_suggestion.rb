class AddTimestampToSuggestion < ActiveRecord::Migration
  def change
    add_column :suggestions, :timestamp, :string
  end
end
