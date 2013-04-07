
class BuildQuiz < Struct.new(:name, :teacher_id, :question_ids, :parent_id) 
  def perform
    quiz = Quiz.new :name => name, :teacher_id => teacher_id, 
                    :question_ids => question_ids, 
                    :num_questions => question_ids.count,
                    :parent_id => parent_id

    status = quiz.save ? :ok : :bad_request
    unless status == :bad_request
      job = Delayed::Job.enqueue CompileQuiz.new(quiz)
      quiz.update_attribute :job_id, job.id
    end

    # @teacher = Teacher.find teacher_id
    # response,status = @teacher.build_quiz_with name, question_ids, parent_id
  end 

  def error(job, exception)
    # Delayed::Job.first/last -> to see details of the objecet stored in the DB
    yaml = YAML.load(job.handler)
    Quiz.where(:teacher_id => yaml.teacher_id).where(compiling > 0).each do |quiz|
      quiz.destroy unless quiz.nil?
    end
  end

end
