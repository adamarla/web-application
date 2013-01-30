class AddReceivedToAnswerSheet < ActiveRecord::Migration
  def change
    add_column :answer_sheets, :received, :boolean, :default => false
  end
end
