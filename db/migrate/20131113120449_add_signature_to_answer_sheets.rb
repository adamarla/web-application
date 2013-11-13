class AddSignatureToAnswerSheets < ActiveRecord::Migration
  def change
    add_column :answer_sheets, :signature, :string, limit: 50
  end
end
