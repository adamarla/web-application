class ExaminersController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create 
    @examiner = Examiner.new params[:examiner] 
    username = create_username_for @examiner, (@examiner.is_admin ? :admin : :examiner) 
    email = params[:examiner].delete(:email) || "#{username}@drona.com" 
    account = @examiner.build_account :email => email, :username => username, 
                                      :password => "123456", :password_confirmation => "123456"

    @examiner.save ? respond_with(@examiner) : head(:bad_request) 
  end 

  def show
    @examiner = Examiner.find params[:id] 
    head :bad_request if @examiner.nil?
  end

  def pending_quizzes
    @quizzes = Examiner.pending_quizzes
  end

  def pending_pages
    quiz = Quiz.find params[:id]
    @pages = Examiner.pages quiz, :pending
  end

  def block_db_slots
    examiner = Examiner.find params[:id]
    slots = examiner.block_db_slots
    render :json => {:slots => slots}, :status => :ok
  end

  def update_workset
    failures = Examiner.receive_scans
    render :json => failures, :status => :ok
  end

end
