class AddPreppedToAnswerSheet < ActiveRecord::Migration
  def change
    add_column :answer_sheets, :prepped, :boolean, :default => false
  end
end
