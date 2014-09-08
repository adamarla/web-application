class PopulateCommentaries < ActiveRecord::Migration
  def up
    Question.all.each do |q|
      tex_ids = q.comments.map(&:id).uniq
      for j in tex_ids 
        q.commentaries.create tex_comment_id: j
      end 
    end 
  end

  def down
  end
end
