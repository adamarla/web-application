class CreateCommentaries < ActiveRecord::Migration
  def change
    create_table :commentaries do |t|
      t.integer :question_id 
      t.integer :tex_comment_id
    end

    add_index :commentaries, :question_id 
    add_index :commentaries, :tex_comment_id
  end
end
