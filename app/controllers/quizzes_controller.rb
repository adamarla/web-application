class QuizzesController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!
  respond_to :json

  def assign_to
    quiz = Quiz.where(:id => params[:id]).first 

    unless quiz.nil?
      publish = params[:publish] == 'yes' 
      teacher = quiz.teacher 
      students = Student.where(:id => params[:checked].keys)
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
        job = Delayed::Job.enqueue CompileTestpaper.new(ws)
        ws.update_attribute :job_id, job.id
        render :json => { :monitor => { :worksheet => ws.id } }, :status => :ok
      else
        render :json => { :monitor => { :worksheet => nil } }, :status => :ok
      end
    else # no valid quiz specified. Should never happen 
      render :json => { :monitor => { :worksheet => nil } }, :status => :ok
    end
  end

  def add_remove_questions
    quiz = Quiz.find params[:id]
    op = params[:op] 

    unless quiz.nil?
      question_ids = params[:checked].nil? ? [] : params[:checked].keys.map(&:to_i)

      if question_ids.count > 0
        msg,subtext = (op == "remove") ? quiz.remove_questions(question_ids) : quiz.add_questions(question_ids)
      else
        msg = quiz.name
        subtext = (op == "remove") ? "No questions dropped" : "No questions added"
      end
      render :json => { :notify => { :text => msg, :subtext => subtext } }, :status => :ok
    else # unless 
      render :json => { :notify => { :text => "Quiz not found" } }, :status => :ok
    end
  end

  def list
    teacher = (current_account.role == :teacher) ? current_account.loggable : nil
    @quizzes = teacher.nil? ? [] : Quiz.where(:teacher_id => teacher.id)

    @disabled = @quizzes.select{ |m| m.compiling? }.map(&:id) 
    n = @quizzes.count 
    @per_pg, @last_pg = pagination_layout_details n
    pg = params[:page].nil? ? 1 : params[:page].to_i
    @quizzes = @quizzes.order('created_at DESC').page(pg).per(@per_pg)
  end

  def questions
    @quiz = Quiz.find params[:id]
    # @questions = quiz.nil? ? [] : quiz.questions
  end 

  def preview
    @quiz = Quiz.where(:id => params[:id]).first
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
    @testpapers = Testpaper.where(:quiz_id => params[:id])
    n = @testpapers.count 
    @per_pg, @last_pg = pagination_layout_details n
    pg = params[:page].nil? ? 1 : params[:page].to_i
    @testpapers = @testpapers.order('created_at DESC').page(pg).per(@per_pg)
  end

end
