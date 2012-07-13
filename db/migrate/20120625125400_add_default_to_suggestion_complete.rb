class AddDefaultToSuggestionComplete < ActiveRecord::Migration
  def change
    change_column :suggestions, :completed, :boolean, :default => false
  end
end
