class RenameMacroTopicToVertical < ActiveRecord::Migration
  def change
    rename_table :macro_topics, :verticals
  end
end
