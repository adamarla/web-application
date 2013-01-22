class QuizzesController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!
  respond_to :json

  def assign_to
    quiz = Quiz.where(:id => params[:id]).first 
    publish = params[:publish] == 'yes' 
    puts " ******* #{publish}"

    head :bad_request if quiz.nil?
    teacher = quiz.teacher 

    students = params[:checked].keys   # we need just the IDs
    Delayed::Job.enqueue BuildTestpaper.new(quiz.id, students, publish), :priority => 0, :run_at => Time.zone.now
    at = Delayed::Job.where('failed_at IS NULL').count
    render :json => { :notify => { :text => "Worksheet received", 
                                   :subtext => "PDF will be ready in #{at} minutes" } }, :status => :ok
  end

  def list
    teacher = (current_account.role == :teacher) ? current_account.loggable : nil
    @quizzes = teacher.nil? ? [] : Quiz.where(:teacher_id => teacher.id).where('atm_key IS NOT NULL')
    @quizzes = params[:klass].nil? ? @quizzes.order(:klass) : @quizzes.where(:klass => params[:klass].to_i)

    n = @quizzes.count 
    @per_pg, @last_pg = pagination_layout_details n
    pg = params[:page].nil? ? 1 : params[:page].to_i
    @quizzes = @quizzes.order('created_at DESC').page(pg).per(@per_pg)
  end

  def preview
    @quiz = Quiz.where(:id => params[:id]).first
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
