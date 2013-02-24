
class EditQuiz < Struct.new(:quiz, :question_ids, :add)

  def perform
    clone = quiz.clone?
    return false if clone.nil?

    current = QSelection.where(:quiz_id => clone.id).map(&:question_id)
    now = add ? (current + question_ids).uniq : (current - question_ids).uniq
    clone.question_ids = now 
    clone.update_attributes :num_questions => now.count, :total => nil, :span => nil
    clone.lay_it_out
    Delayed::Job.enqueue CompileQuiz.new(clone), :priority => 0, :run_at => Time.zone.now
  end 

end
