class RenameAnswerSheetToWorksheet < ActiveRecord::Migration
  def change
    rename_table :answer_sheets, :worksheets
  end
end
