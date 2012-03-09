
class BuildTestpaper < Struct.new(:quiz_id, :student_ids)
  def perform
    @quiz = Quiz.where(:id => quiz_id).first
    @students = Student.where(:id => student_ids)

    if @students.blank?
      puts "*******************"
      puts " Empty student list"
      puts "*******************"
    else
      @quiz.assign_to @students
    end

  end

end
