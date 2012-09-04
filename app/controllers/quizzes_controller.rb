class QuizzesController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def assign_to
    quiz = Quiz.where(:atm_key => params[:id]).first 
    head :bad_request if quiz.nil?
    teacher = quiz.teacher 

    students = params[:checked].keys   # we need just the IDs
    Delayed::Job.enqueue BuildTestpaper.new(quiz.id, students), :priority => 0, :run_at => Time.zone.now
    at = Delayed::Job.where('failed_at IS NULL').count
    render :json => { :status => "Queued", :at => at }, :status => :ok
  end

  def list
    teacher = (current_account.role == :teacher) ? current_account.loggable : nil
    @quizzes = teacher.nil? ? [] : Quiz.where(:teacher_id => teacher.id).where('atm_key IS NOT NULL').order(:klass).order('created_at DESC')
  end

  def preview
    @quiz = Quiz.where(:atm_key => params[:id]).first
    head :bad_request if @quiz.nil?
  end

  def pending_pages
    @quiz = Quiz.find params[:id]
    @examiner = Examiner.find params[:examiner_id]
    head :bad_request if (@quiz.nil? || @examiner.nil?)

    @pages = @quiz.pending_pages @examiner
    respond_with @pages, @examiner, @quiz
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
    @quiz = Quiz.where(:atm_key => params[:id]).first
    head :bad_request if @quiz.nil? 
    @testpapers = Testpaper.where(:quiz_id => @quiz.id).order(:created_at)
    respond_with @testpapers, @quiz
  end

end
