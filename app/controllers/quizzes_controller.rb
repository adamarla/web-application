class QuizzesController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!, except: [ :daily ]
  respond_to :json

  def daily 
    DailyQuiz.next 
  end 

  def build
    t = current_account.loggable
    name = params[:qzb][:name]
    qids = params[:q].keys.map(&:to_i)

    quiz = t.quizzes.create(name: name, question_ids: qids, num_questions: qids.count)
    eta = minutes_to_completion quiz.job_id
    render json: { monitor: { quizzes: [quiz.id] }, notify: { title: "#{eta} minutes(s)" } }, status: :ok
  end

  def ping
    # This action is only for our individual offering. Invoked only by a student 
    # subscribing to quizzes made by us 
    @qid = params[:id].to_i
    @sid = current_account.loggable_id # must be a student
    @w = Worksheet.of_student(@sid).select{ |j| j.exam.quiz_id == @qid }.first
  end

  def mass_assign_to
    quiz = Quiz.find params[:id]

    unless quiz.nil?
      take_home = !(params[:etype] == 'classwork')
      t = quiz.teacher 
      students = Student.where(id: params[:checked].keys)

      eid, job_id = students.blank? ? nil : quiz.mass_assign_to(students, take_home)
      unless job_id.nil? 
        eta = minutes_to_completion job_id
        r = { monitor: { exams: [eid] }, notify: { title: "#{eta} minute(s)" }}
      else 
        # either because the quiz is being published OR
        # mass_assignment called by an indie teacher (not allowed)
        r = { msg: :take_home }
      end

      # For now, allow only offline teachers to specify any additional deadlines for the exam
      r[:meta] = { id: eid } unless t.indie
      render json: r, status: :ok
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
          Mailbot.delay.quiz_shared(clone, current_account.loggable, t) if account.has_email?
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
        @last_child = quiz.exam_ids.count > 0 ? quiz.children?.order(:created_at).last : quiz
      else
        @title = "No change"
        @msg = (op == "remove") ? "No questions dropped" : "No questions added"
      end
    else # should never happen 
      @title = "Quiz not found"
    end
  end

  def list 
    t = current_account.loggable 
    @quizzes = Quiz.where(teacher_id: t.id)
    @disabled = @quizzes.select{ |j| j.compiling? }.map(&:id)
    @ping = @quizzes.count 
    @per_pg, @last_pg = pagination_layout_details @ping
    pg = params[:page].nil? ? 1 : params[:page].to_i
    @quizzes = @quizzes.order('created_at DESC').page(pg).per(@per_pg)
    @indie = t.indie
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
    @exams = Exam.where(quiz_id: params[:id]).order(:created_at).reverse_order
    n = @exams.count 
    @per_pg, @last_pg = pagination_layout_details n
    pg = params[:page].nil? ? 1 : params[:page].to_i
    @exams = @exams.page(pg).per(@per_pg)
  end

  def pay_to_grade
    qid = params[:id].to_i
    w = Worksheet.of_student(current_account.loggable_id).select{ |j| j.exam.quiz_id == qid }.first

    unless w.nil?
      w.bill
      render json: { id: w.id }, status: :ok
    else
      render json: { status: :failed }, status: :ok
    end
  end

end
