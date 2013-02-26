
class BuildTestpaper < Struct.new(:quiz, :student_ids, :publish)
  def perform
    students = Student.where(:id => student_ids)
=begin
    If: 
      1. this quiz is a clone of some other quiz
      2. this the first worksheet being made for this quiz

    Then, its time to re-name the quiz by appending a time-stamp to it. 
    Time stamps would be be our way of maintaining versioning information
=end
    unless quiz.parent_id.nil?
      unless quiz.testpaper_ids.count > 0
        name = quiz.name 
        name = name.sub "(edited)", "#{Date.today.strftime('%b %Y')}"
        quiz.update_attribute :name, name
      end
    end
    
    # issue request only after re-naming
    quiz.assign_to(students, publish) unless students.blank?
  end

end
