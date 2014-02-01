class AddTexCommentIdToRemarks < ActiveRecord::Migration
  def change
    add_column :remarks, :tex_comment_id, :integer
  end
end
