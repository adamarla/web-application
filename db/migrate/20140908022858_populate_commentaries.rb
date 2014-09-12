class PopulateCommentaries < ActiveRecord::Migration
  def up
    Question.all.each do |q|
      a_ids = Attempt.graded.where(subpart_id: q.subpart_ids)
      tex_ids = Remark.where(attempt_id: a_ids).map(&:tex_comment_id).uniq
      for j in tex_ids 
        q.commentaries.create tex_comment_id: j
      end 
    end 
  end

  def down
  end
end
