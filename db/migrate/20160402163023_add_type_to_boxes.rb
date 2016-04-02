class AddTypeToBoxes < ActiveRecord::Migration
  def up
    remove_column :boxes, :of_questions
    remove_column :boxes, :of_snippets
    remove_column :boxes, :of_skills
    add_column :boxes, :contains, :string, limit: 20
  end 

  def down
    add_column :boxes, :of_questions, :boolean, default: false 
    add_column :boxes, :of_snippets, :boolean, default: false 
    add_column :boxes, :of_skills, :boolean, default: false 
    remove_column :boxes, :contains
  end 

end
