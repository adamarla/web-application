class AddIndexesToQSelection < ActiveRecord::Migration
  def change
    add_index :q_selections, :quiz_id
    add_index :q_selections, :question_id
  end
end
