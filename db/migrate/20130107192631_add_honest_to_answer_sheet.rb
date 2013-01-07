class AddHonestToAnswerSheet < ActiveRecord::Migration
  def change
    add_column :answer_sheets, :honest, :integer
  end
end
