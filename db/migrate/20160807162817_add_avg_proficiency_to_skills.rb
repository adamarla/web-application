class AddAvgProficiencyToSkills < ActiveRecord::Migration
  def change
    add_column :skills, :avg_proficiency, :float, default: 0
  end
end
