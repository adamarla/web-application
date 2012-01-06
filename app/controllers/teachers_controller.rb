class TeachersController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create 
    school = School.find params[:id] 
    head :bad_request if school.nil? 
    
    subjects = params[:teacher].delete :subjects
    @teacher = Teacher.new params[:teacher]
    @teacher.school = school 

    # Prepare data for teacher's account
    username = @teacher.generate_username
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

  def applicable_macros
    teacher = (current_account.role == :teacher) ? current_account.loggable : nil
    head :bad_request if teacher.nil?

    subject = params[:criterion][:subject]
    klass = params[:criterion][:klass]
    board = teacher.school.board_id

    course = Course.where(:board_id => board, :klass => klass, :subject_id => subject).first
    @macros = course.nil? ? nil : course.macros
    @macros.nil? ? head(:bad_request) : respond_with(@macros)
  end

  def update 
    head :ok 
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

    @study_groups = StudyGroup.where(:school_id => @teacher.school_id).order(:klass).order(:section)
    respond_with @study_groups, @teacher
  end 

  def update_roster
    teacher = Teacher.find params[:id] 
    head :bad_request if teacher.nil? 

    roster = params[:checked] # a hash with (key, value) = (id, boolean)
    retain = [] 

    roster.each { |id, teaches| 
      study_group = StudyGroup.find id 
      unless study_group.nil? 
        retain << study_group if teaches 
      end 
    }
    teacher.study_groups = retain 
    head :ok
  end 

end # of class
