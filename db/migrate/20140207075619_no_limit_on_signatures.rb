class NoLimitOnSignatures < ActiveRecord::Migration
  def up
    change_column :quizzes, :page_breaks_after, :string
    change_column :quizzes, :switch_versions_after, :string
    change_column :worksheets, :signature, :string
  end

  def down
    change_column :quizzes, :page_breaks_after, :string, limit: 100
    change_column :quizzes, :switch_versions_after, :string, limit: 100
    change_column :worksheets, :signature, :string, limit: 50
  end
end
