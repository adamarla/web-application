class TeachersController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create 
    school = School.find params[:id] 
    head :bad_request if school.nil? 
    
    subjects = params[:teacher].delete(:subjects) || []
    @teacher = Teacher.new params[:teacher]
    @teacher.school = school 

    # Prepare data for teacher's account
    username = create_username_for @teacher, :teacher 
    email = params[:teacher].delete(:email) || "#{username}@drona.com"
    password = school.zip_code

    unless username.nil? 
      account = @teacher.build_account :email => email, :username => username, 
                  :password => password, :password_confirmation => password
      @teacher.set_subjects subjects 
      (@teacher.save) ? respond_with(@teacher) : :bad_request
    else
      head :bad_request
    end 
  end # of create
 
  def show 
    render :nothing => true, :layout => 'teachers'
  end 

  def load
    @teacher = Teacher.find params[:id]
  end

  def coverage
    # Returns the list of macro-topics covered by the teacher for the passed
    # (class, subject, board) combo

    teacher = (current_account.role == :teacher) ? current_account.loggable : nil
    head :bad_request if teacher.nil?

    subject = params[:criterion][:subject]
    klass = params[:criterion][:klass]
    board = teacher.school.board_id

    course = Course.where(:board_id => board, :klass => klass, :subject_id => subject).first
    @macros = course.nil? ? nil : course.macros
    @macros.nil? ? head(:bad_request) : respond_with(@macros)
  end

  def courses
    teacher = Teacher.find params[:id]
    head :bad_request if teacher.nil? 
    @courses = teacher.courses
  end

  def update 
    teacher = Teacher.find params[:id]
    head :bad_request if teacher.nil?
    status = teacher.update_attributes(params[:teacher]) ? :ok : :bad_request
    head status 
  end 

  def list 
    if current_account
      @who_wants_to_know = current_account.role
      case @who_wants_to_know
        when :admin
          @teachers = Teacher.where(:school_id => params[:id])
        when :school 
          @teachers = Teacher.where(:school_id => current_account.loggable.id)
        when :student 
          @teachers = current_account.loggable.teachers 
        else 
          @teachers = [] 
      end 
      respond_with @teachers, @who_wants_to_know
    else
      head :bad_request 
    end 
  end 

  def roster 
    @teacher = Teacher.find params[:id] 
    head :bad_request if @teacher.nil? 

    @sektions = Sektion.where(:school_id => @teacher.school_id).order(:klass).order(:section)
    respond_with @sektions, @teacher
  end 

  def update_roster
    teacher = Teacher.find params[:id] 
    head :bad_request if teacher.nil? 

    roster = params[:checked] # a hash with (key, value) = (id, boolean)
    retain = [] 

    roster.each { |id, teaches| 
      sektion = Sektion.find id 
      unless sektion.nil? 
        retain << sektion if teaches 
      end 
    }
    teacher.sektions = retain 
    head :ok
  end 

  def build_quiz 
    teacher = Teacher.find params[:id]
    course = Course.find params[:course_id]
    head :bad_request if (teacher.nil? || course.nil?)

    question_ids = params[:checked].keys.map(&:to_i)
    response, status = teacher.build_quiz_with question_ids, course
    render :json => response, :status => status
  end

end # of class
