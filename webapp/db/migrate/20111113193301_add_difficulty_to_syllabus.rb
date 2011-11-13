class AddDifficultyToSyllabus < ActiveRecord::Migration
  def change
    add_column :syllabi, :difficulty, :integer, :default => 0
  end
end
