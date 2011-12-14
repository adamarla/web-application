class AddSubpartToGradeDescription < ActiveRecord::Migration
  def change
    add_column :grade_descriptions, :subpart, :boolean, :default => false
  end
end
