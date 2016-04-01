class QuestionInPrepwell < ActiveRecord::Migration
  def up
    add_column :questions, :chapter_id, :integer 
    add_column :questions, :language_id, :integer 

    remove_column :questions, :topic_id
    remove_column :questions, :n_picked

    rename_column :questions, :available, :live
    change_column_default :questions, :live, false 

    add_index :questions, :chapter_id 
    add_index :questions, :language_id
  end

  def down
    remove_column :questions, :chapter_id 
    remove_column :questions, :language_id  

    add_column :questions, :topic_id, :integer 
    add_column :questions, :n_picked, :integer, default: 0

    rename_column :questions, :live, :available 
    add_index :questions, :topic_id
  end
end
