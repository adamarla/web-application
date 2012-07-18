class RenameFileSignatureInSuggestion < ActiveRecord::Migration
  def change 
    rename_column :suggestions, :filesignature, :signature
  end
end
