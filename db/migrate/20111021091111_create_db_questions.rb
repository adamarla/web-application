class CreateDbQuestions < ActiveRecord::Migration
  def change
    create_table :db_questions do |t|
      t.string :path
      t.integer :attempts, :default => 0
      t.integer :flags, :default => 0

      t.timestamps
    end
  end
end
