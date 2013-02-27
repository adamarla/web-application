
class CompileQuiz < Struct.new(:quiz)
  def perform
    question_ids = QSelection.where(:quiz_id => quiz.id).map(&:question_id)
    n_questions = question_ids.count 
    quiz.update_attributes :num_questions => n_questions, :total => nil, :span => nil
    quiz.lay_it_out

    response = quiz.compile_tex unless quiz.nil?
    manifest = response[:manifest]
    status = manifest.blank? ? :bad_request : :ok

    unless status == :bad_request
      atm = Quiz.extract_atm_key manifest[:root]
      span = manifest[:image].class == Array ? manifest[:image].count : 1
      quiz.update_attributes :atm_key => atm, :span => span
      response = {:atm_key => atm, :name => quiz.name }

      # Increment n_picked for each of the questions picked for this quiz
      Question.where(:id => question_ids).each do |m|
        m.increment_picked_count
      end
    else
      quiz.destroy
    end

  end 
end
