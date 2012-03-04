
class BuildQuiz < Struct.new(:teacher_id, :question_ids, :course)
  def perform
    @teacher = Teacher.find teacher_id
    response,status = @teacher.build_quiz_with question_ids, course
  end 

  def error(job, exception)
    # Delayed::Job.first/last -> to see details of the objecet stored in the DB
    yaml = YAML.load(job.handler)
    quiz = Quiz.where(:teacher_id => yaml.teacher_id, :subject_id => yaml.course.subject_id,
                      :klass => yaml.course.klass).where('atm_key IS NULL').first

    quiz.destroy unless quiz.nil?
  end

end
