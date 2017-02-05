class SkillSpecificParcels < ActiveRecord::Migration
  def change 
    add_column :parcels, :skill_id, :integer, default: 0
  end 
end
