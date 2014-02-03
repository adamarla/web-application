class RemarksToCommentsTransfer < ActiveRecord::Migration
  def up
    
    # First, a simple transfer
    remarks = Remark.all
    for r in remarks 
      e = r.graded_response.examiner_id 
      t = TexComment.new text: r.tex, examiner_id: e
      t.save if t.valid?
    end 
    
    # Update the tex_comment_id field in every Remark
    comments = TexComment.all
    for c in comments 
      Remark.where(tex: c.text).map{ |j| j.update_attribute(:tex_comment_id, c.id) }
    end
  end

  def down
    comments = TexComment.all 
    for c in comments 
      Remark.where(tex_comment_id: c.id).map{ |j| j.update_attribute(:tex, c.text) }
    end 
  end
end
