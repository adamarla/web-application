
class CompileQuiz < Struct.new(:quiz)
  def perform
    quiz.compile_tex unless quiz.nil?
  end 
end
