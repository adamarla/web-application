class UpPgBreaksAndVersionColumnLimit < ActiveRecord::Migration
  def up
    change_column :quizzes, :page_breaks_after, :string, limit: 100
    change_column :quizzes, :switch_versions_after, :string, limit: 100
  end

  def down
    change_column :quizzes, :page_breaks_after, :string, limit: 30 
    change_column :quizzes, :switch_versions_after, :string, limit: 30
  end
end
