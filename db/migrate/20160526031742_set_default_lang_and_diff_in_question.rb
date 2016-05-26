class SetDefaultLangAndDiffInQuestion < ActiveRecord::Migration
  def up
    difficulty = Difficulty.named 'medium' 
    language = Language.named 'English' 

    change_column_default :questions, :difficulty, difficulty 
    change_column_default :questions, :language_id, language
  end

  def down
  end
end
