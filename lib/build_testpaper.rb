
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
    
    # issue request only after re-naming
  end

end
