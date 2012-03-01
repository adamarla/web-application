class ExaminersController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create 
    added = true
    params[:examiners].each_value do |v,index|
      name = v[:name]
      as_admin = v[:admin].blank? ? false : true

      next if name.blank?
      #puts "#{name} --> #{as_admin}"

      examiner = Examiner.new :name => name, :is_admin => as_admin
      username = create_username_for examiner, (as_admin ? :admin : :examiner)
      email = "#{username}@drona.com" # default. Can be changed later by the examiner
      account = examiner.build_account :email => email, :username => username, 
                                       :password => "123456", :password_confirmation => "123456"
      added &= examiner.save
      break if !added 
    end
    added ? head(:ok) : head(:bad_request)
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
