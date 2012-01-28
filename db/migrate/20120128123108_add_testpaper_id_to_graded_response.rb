class AddTestpaperIdToGradedResponse < ActiveRecord::Migration
  def change
    add_column :graded_responses, :testpaper_id, :integer
  end
end
