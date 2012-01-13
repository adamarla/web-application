class RemovePgAndIndexFromResponse < ActiveRecord::Migration
  def up
    remove_column :graded_responses, :on_page
    remove_column :graded_responses, :index_in_quiz
  end

  def down
    add_column :graded_responses, :on_page, :integer
    add_column :graded_responses, :index_in_quiz, :integer
  end
end
