class AddPagesToSuggestions < ActiveRecord::Migration

  def change 
    add_column :suggestions, :pages, :integer, :default => 1
  end
end
