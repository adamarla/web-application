
class BuildQuiz < Struct.new(:name, :teacher_id, :question_ids, :parent_id) 
  def perform
    @teacher = Teacher.find teacher_id
    response,status = @teacher.build_quiz_with name, question_ids, parent_id
  end 

  def error(job, exception)
    # Delayed::Job.first/last -> to see details of the objecet stored in the DB
    yaml = YAML.load(job.handler)
    quiz = Quiz.where(:teacher_id => yaml.teacher_id, :subject_id => yaml.course.subject_id,
                      :klass => yaml.course.klass).where('atm_key IS NULL').first

    quiz.destroy unless quiz.nil?
  end

end
