class CreateBundleQuestions < ActiveRecord::Migration
  def change
    create_table :bundle_questions do |t|
      t.integer :bundle_id
      t.integer :question_id

      t.timestamps
    end
    add_index :bundle_questions, :bundle_id
  end
end
