class CreateSubparts < ActiveRecord::Migration
  def change
    create_table :subparts do |t|
      t.integer :question_id
      t.boolean :mcq, :default => false
      t.boolean :half_page, :default => false
      t.boolean :full_page, :default => true
      t.integer :marks
      t.boolean :multi_correct, :default => false
    end
  end
end
