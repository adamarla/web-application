class AddParentSkillToSkill < ActiveRecord::Migration
  def change
    add_column :skills, :parent_skill_id, :integer
  end


end
