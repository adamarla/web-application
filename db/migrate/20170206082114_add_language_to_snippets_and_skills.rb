class AddLanguageToSnippetsAndSkills < ActiveRecord::Migration
  def change
    language = Language.named 'English' 

    add_column :skills, :language_id, :integer, default: language 
    add_column :snippets, :language_id, :integer, default: language 
  end
end
