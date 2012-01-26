class QuizzesController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json, :xml

  def create
    # teachers/behaviour.js.coffee is where this POST request was structured
    teacher = Teacher.find params[:id]
    selected = params[:selected]

    selected.each_with_index do |q, index|
      selected[index] = q.to_i
    end

    subject = Subject.where(:name => params[:subject]).select(:id).first.id
    @quiz = Quiz.new :teacher_id => teacher.id, :question_ids => selected, 
                     :num_questions => selected.count, :subject_id => subject, 
                     :klass => params[:klass]
    status = @quiz.save ? :ok : :bad_request
    head status
  end 

  def assign_to
    quiz = Quiz.find params[:id]
    head :bad_request if quiz.nil?

    students = Student.where(:id => params[:checked].keys)
    id_names = []
    #id_names = students.map { |k| id_names.push({ k.id.to_s => k.name }) } # [{ 1 => 'Abhinav' } ... ]
    students.each do |s|
      id_names.push({ :id => s.id, :name => s.name })
    end

    client = Savon::Client.new do
      wsdl.document = "http://localhost:8080/axis2/services/documentMaster?wsdl"
      wsdl.endpoint = "http://localhost:8080/axis2/services/documentMaster"
    end
   client.http.headers["SOAPAction"] = '"http://gutenberg/blocs/assignQuiz"'
   response = client.request :wsdl, :assignQuiz do  
     soap.body = { 
       :quiz => {
         #:id => "#{quiz.id}-#{Time.now.strftime('%H%M')}",
         :id => "#{quiz.id}",
         :teacher_id => quiz.teacher_id,
         :page => quiz.layout?
       },
       :students => id_names 
     } 
   end
   head :ok
    #head quiz.assign_to students
  end

  def get_candidates
    board = params[:board_id]
    klass = params[:criterion][:klass]
    subject = params[:criterion][:subject]
    topics = params[:checked].nil? ? [] : params[:checked].keys

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
    @quizzes = teacher.nil? ? [] : Quiz.where(:teacher_id => teacher.id).order(:klass)
  end

  def preview
    quiz = Quiz.find params[:id]
    @questions = quiz.nil? ? [] : quiz.questions
  end

end
