class RenameTimestampInSuggestion < ActiveRecord::Migration
  def change
    rename column :suggestions, :timestamp, :filesignature
  end
end
