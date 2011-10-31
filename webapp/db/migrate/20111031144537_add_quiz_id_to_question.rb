class AddQuizIdToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :quiz_id, :integer
  end
end
