
class CompileQuiz < Struct.new(:quiz)
  def perform
    response = quiz.compile_tex unless quiz.nil?
    manifest = response[:manifest]
    status = manifest.blank? ? :bad_request : :ok

    unless status == :bad_request
      atm = Quiz.extract_atm_key manifest[:root]
      span = manifest[:image].class == Array ? manifest[:image].count : 1
      quiz.update_attributes :atm_key => atm_key, :span => span
      response = {:atm_key => atm_key, :name => quiz.name }

      # Increment n_picked for each of the questions picked for this quiz
      Question.where(:id => question_ids).each do |m|
        m.increment_picked_count
      end
    else
      quiz.destroy
    end

  end 
end
