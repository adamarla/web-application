class QuizzesController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!
  respond_to :json

  def assign_to
    quiz = Quiz.find params[:id]

    unless quiz.nil?
      publish = !(params[:ws_type] == 'classwork')
      teacher = quiz.teacher 
      students = Student.where(id: params[:checked].keys)
=begin
      Now, if this quiz is a clone of some other quiz AND this is the 
      first worksheet being made for it, then its time to seal the name 
      of this quiz. Hereonafter, editing this quiz would result in a clone
=end
      unless quiz.parent_id.nil?
        unless quiz.testpaper_ids.count > 0
          name = quiz.name 
          name = name.sub "(edited)", "(#{Date.today.strftime('%m/%y')})"
          quiz.update_attribute :name, name
        end
      end

      ws = students.blank? ? nil : quiz.assign_to(students, publish)
      unless ws.nil? # time to compile
        job = Delayed::Job.enqueue CompileTestpaper.new(ws), priority: 0
        ws.update_attribute :job_id, job.id

        estimate = minutes_to_completion job.id
        render json: { monitor: { worksheet: ws.id }, notify: {title: "#{estimate} minute(s)" }}, status: :ok
      else
        render json: { monitor: {worksheet: nil } }, status: :ok
      end
    else # no valid quiz specified. Should never happen 
      render json: { monitor: { worksheet: nil } }, status: :ok
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
      if already_shared 
        render json: { status: :donothing }, status: :ok
      else 
        orig = Quiz.find params[:id]
        clone = orig.nil? ? nil : orig.clone(t.id)
        unless clone.nil?
          job = Delayed::Job.enqueue CompileQuiz.new(clone.id), priority: 5
          clone.update_attribute :job_id, job.id

          estimate = minutes_to_completion job.id
          Mailbot.delay.quiz_shared(clone, current_account.loggable, t) if account.email_is_real?
          render :json => { :monitor => { :quiz => clone.id }, 
                            :notify => { :title => "#{estimate} minute(s)" }},
                            status: :ok
        else
          clone.destroy
          render json: { status: :error }, status: :ok
        end # unless clone.nil?
      end # already_shared
    end
  end


  def add_remove_questions
    quiz = Quiz.find params[:id]
    op = params[:op] 
    @clone = nil

    unless quiz.nil?
      question_ids = params[:checked].nil? ? [] : params[:checked].keys.map(&:to_i)

      if question_ids.count > 0
        @title, @msg = (op == "remove") ? quiz.remove_questions(question_ids) : quiz.add_questions(question_ids)
        @clone = quiz.clone?
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
    @uid = encrypt(@quiz.id, 7)
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

  def testpapers
    @testpapers = Testpaper.where(quiz_id: params[:id])
    n = @testpapers.count 
    @per_pg, @last_pg = pagination_layout_details n
    pg = params[:page].nil? ? 1 : params[:page].to_i
    @testpapers = @testpapers.order('created_at DESC').page(pg).per(@per_pg)
  end

end
