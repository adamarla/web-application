class AddGenericToSkill < ActiveRecord::Migration
  def change
    add_column :skills, :generic, :boolean, default: false
  end
end
