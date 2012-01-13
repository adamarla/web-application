class QuizzesController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create
    # teachers/behaviour.js.coffee is where this POST request was structured
    teacher = Teacher.find params[:id]
    selected = params[:selected]

    selected.each_with_index do |q, index|
      selected[index] = q.to_i
    end

    @quiz = Quiz.new :teacher_id => teacher.id, :question_ids => selected, :num_questions => selected.count
    @quiz.set_name params[:klass], params[:subject]

    status = @quiz.save ? :ok : :bad_request
    head status
  end 

  def assign_to
    quiz = Quiz.find params[:id]
    head :bad_request if quiz.nil?

    students = Student.where :id => params[:checked].keys
    head quiz.assign_to students
  end

  def get_candidates
    board = params[:board_id]
    klass = params[:criterion][:klass]
    subject = params[:criterion][:subject]
    topics = params[:checked].keys

    @questions = []
    course = Course.where(:board_id => board, :klass => klass, :subject_id => subject).first 

    head :bad_request if course.nil?

    topics.each do |topic|
      difficulty = Syllabus.where(:course_id => course.id, :micro_topic_id => topic).select(:difficulty).first.difficulty
      @questions |= Question.where(:micro_topic_id => topic, :difficulty => difficulty)
    end 
    respond_with @questions
  end

  def list
    teacher = (current_account.role == :teacher) ? current_account.loggable : nil
    @quizzes = teacher.nil? ? [] : Quiz.where(:teacher_id => teacher.id)
  end

  def preview
    quiz = Quiz.find params[:id]
    @questions = quiz.nil? ? [] : quiz.questions
  end

end
