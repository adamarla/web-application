class AddUsedCountToTexComment < ActiveRecord::Migration
  def up
    add_column :tex_comments, :n_used, :integer, default: 0
    ids = Remark.all.map(&:tex_comment_id).uniq
    for j in ids 
      n = Remark.where(tex_comment_id: j).count
      TexComment.find(j).update_attribute(:n_used, n)
    end 
  end

  def down
    remove_column :tex_comments, :n_used
  end 
end
