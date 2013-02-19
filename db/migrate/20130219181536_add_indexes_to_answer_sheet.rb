class AddIndexesToAnswerSheet < ActiveRecord::Migration
  def change
    add_index :answer_sheets, :student_id
    add_index :answer_sheets, :testpaper_id
  end
end
