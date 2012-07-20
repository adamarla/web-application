
# This job is ONLY for when an examiner is blocking slots in response 
# to a new, incoming suggestion and NOT for the normal course when he/she
# blocks slots to write his/her own new question

class BlockDbSlots < Struct.new(:n_slots, :suggestion_id)
  def perform
    suggestion = Suggestion.find suggestion_id
    return false if suggestion.nil? 

    # Remember, by now, suggestions have already been distributed amongst examiners
    # and have been identified as coming from a specific teacher

    examiner = Examiner.find suggestion.examiner_id 
    return false if examiner.nil?

    slots = examiner.block_db_slots n_slots # slots = array of question uids
    questions = Question.where(:uid => slots)

    # Complete suggestion <-> questions mapping 
    suggestion.question_ids = questions.map(&:id) 

    # Add questions to teacher's favourites
    t = Teacher.find suggestion.teacher_id
    unless t.nil?
      questions.each do |q|
        f = t.favourites.new :question_id => q.id
        f.save
      end
    end
  end # of method 

end # of class
