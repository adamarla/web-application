class AddMcqFlagsToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :mcq, :boolean, :default => false
    add_column :questions, :multi_correct, :boolean, :default => false
  end
end
