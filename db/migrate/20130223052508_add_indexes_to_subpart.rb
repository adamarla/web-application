class AddIndexesToSubpart < ActiveRecord::Migration
  def change
    add_index :subparts, :question_id
  end
end
