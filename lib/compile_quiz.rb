
class CompileQuiz < Struct.new(:id)
  def perform
    quiz = Quiz.find id
    question_ids = QSelection.where(quiz_id: id).map(&:question_id)
    n_questions = question_ids.count 

    quiz.update_attributes num_questions: n_questions, total: nil, span: nil
    page_breaks, version_triggers = quiz.lay_it_out

    response = quiz.compile_tex page_breaks, version_triggers
    manifest = response[:manifest]
    status = manifest.blank? ? :bad_request : :ok

    unless status == :bad_request
      span = manifest[:image].class == Array ? manifest[:image].count : 1
      quiz.update_attributes :job_id => 0, :span => span
      response = { :name => quiz.name }

      # Increment n_picked for each of the questions picked for this quiz
      Question.where(:id => question_ids).each do |m|
        m.increment_picked_count
      end
    else
      raise "[Quiz = #{id}]: TeX compilation failed"
    end
  end 

  def failure(job)
    id = YAML.load(job.handler).id
    quiz = Quiz.find id
    quiz.destroy unless quiz.nil?
  end

end
