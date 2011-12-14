class AddDifficultyToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :difficulty, :integer, :default => 0
  end
end
