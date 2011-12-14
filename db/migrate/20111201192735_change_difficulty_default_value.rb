class ChangeDifficultyDefaultValue < ActiveRecord::Migration
  def up
    change_column :syllabi, :difficulty, :integer, :default => 1
    change_column :questions, :difficulty, :integer, :default => 1

    Syllabus.reset_column_information
    Syllabus.all.each { |s| s.update_attribute(:difficulty, 1) if s.difficulty == 0 }

    Question.reset_column_information
    Question.all.each { |q| q.update_attribute(:difficulty, 1) if q.difficulty == 0 }

  end

  def down
    change_column :syllabi, :difficulty, :integer, :default => 0
    change_column :questions, :difficulty, :integer, :default => 0
  end

end
