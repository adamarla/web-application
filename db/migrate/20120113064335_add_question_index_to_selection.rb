class AddQuestionIndexToSelection < ActiveRecord::Migration
  def change
    add_column :q_selections, :index, :integer
  end
end
