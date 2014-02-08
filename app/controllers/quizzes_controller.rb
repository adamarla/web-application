class QuizzesController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!
  respond_to :json

  def build
    p = params[:checked]
    t = current_account.loggable
    name = p.delete :name
    qids = p.keys.map(&:to_i)

    quiz = t.quizzes.create(name: name, question_ids: qids, num_questions: qids.count)
    eta = minutes_to_completion quiz.job_id
    render json: { monitor: { quiz: [quiz.id] }, notify: { title: "#{eta} minutes(s)" } }, status: :ok
  end

  def mass_assign_to
    quiz = Quiz.find params[:id]

    unless quiz.nil?
      publish = !(params[:ws_type] == 'classwork')
      teacher = quiz.teacher 
      students = Student.where(id: params[:checked].keys)

      eid, job_id = students.blank? ? nil : quiz.mass_assign_to(students, publish)
      unless job_id.nil? 
        eta = minutes_to_completion job_id
        render json: { monitor: { exam: [eid] }, notify: { title: "#{eta} minute(s)" }}, status: :ok
      else # should happen because the quiz IS being published - and no other reason
        render json: { msg: :publish }, status: :ok
      end 
    else
      render json: { msg: 'No quiz found!' }, status: :ok
    end
  end

  def share
    email = params[:share][:email]
    account = Account.where(email: email).first 

    if account.nil? || account.loggable_type != "Teacher" 
      render json: { status: :missing }, status: :ok
    else
      t = account.loggable
      already_shared = !Quiz.where(teacher_id: t.id, parent_id: params[:id]).empty?
      unless already_shared
        orig = Quiz.find params[:id]
        clone = orig.nil? ? nil : orig.clone(t.id)
        unless clone.nil?
          Mailbot.delay.quiz_shared(clone, current_account.loggable, t) if account.email_is_real?
        end 
      end # already_shared
      render json: { status: :ok }, status: :ok
    end
  end


  def add_remove_questions
    quiz = Quiz.find params[:id]
    op = params[:op] 
    @last_child = nil

    unless quiz.nil?
      question_ids = params[:checked].nil? ? [] : params[:checked].keys.map(&:to_i)

      if question_ids.count > 0
        @title, @msg = (op == "remove") ? quiz.remove_questions(question_ids) : quiz.add_questions(question_ids)
        @last_child = quiz.children?.order(:created_at).last
      else
        @title = "No change"
        @msg = (op == "remove") ? "No questions dropped" : "No questions added"
      end
    else # should never happen 
      @title = "Quiz not found"
    end
  end

  def list
    teacher = (current_account.role == :teacher) ? current_account.loggable : nil

    unless teacher.nil?
      @quizzes = Quiz.where(teacher_id: teacher.id)
      @quizzes = @quizzes.blank? ? Quiz.where(id: 318) : @quizzes # 318 = "A Demo Quiz" 

      @disabled = @quizzes.select{ |m| m.compiling? }.map(&:id) 
      n = @quizzes.count 
      @per_pg, @last_pg = pagination_layout_details n
      pg = params[:page].nil? ? 1 : params[:page].to_i
      @quizzes = @quizzes.order('created_at DESC').page(pg).per(@per_pg)
    else
      @quizzes = []
    end
  end

  def questions
    @quiz = Quiz.find params[:id]
    # @questions = quiz.nil? ? [] : quiz.questions
  end 

  def preview
    @quiz = Quiz.where(id: params[:id]).first
    head :bad_request if @quiz.nil?
  end

  def pending_scans
    @quiz_id = params[:id] # need to pass onto RABL
    quiz = Quiz.find @quiz_id 

    examiner = Examiner.find params[:examiner_id]
    page = params[:page].nil? ? -1 : params[:page].to_i
    head :bad_request if (quiz.nil? || examiner.nil? || page < 0) 

    @students, @pending, @scans = quiz.pending_scans examiner.id, page
  end

  def exams
    @exams = Exam.where(quiz_id: params[:id])
    n = @exams.count 
    @per_pg, @last_pg = pagination_layout_details n
    pg = params[:page].nil? ? 1 : params[:page].to_i
    @exams = @exams.order('created_at DESC').page(pg).per(@per_pg)
  end

end
