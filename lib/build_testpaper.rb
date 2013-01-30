
class BuildTestpaper < Struct.new(:quiz_id, :student_ids, :publish)
  def perform
    @quiz = Quiz.where(:id => quiz_id).first
    @students = Student.where(:id => student_ids)

    @quiz.assign_to(@students, publish) unless @students.blank?
  end

end
