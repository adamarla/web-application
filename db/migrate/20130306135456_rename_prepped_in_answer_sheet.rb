class RenamePreppedInAnswerSheet < ActiveRecord::Migration
  def change 
    rename_column :answer_sheets, :prepped, :compiled
  end 
end
