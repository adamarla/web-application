class RenameTimestampInSuggestion < ActiveRecord::Migration
  def change
    rename_column :suggestions, :timestamp, :filesignature
  end
end
