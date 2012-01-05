class TeachersController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create 
    school = School.find params[:id] 
    head :bad_request if school.nil? 
    
    @teacher = Teacher.new params[:teacher]
    username = @teacher.generate_username
    email = params[:teacher].delete(:email) || "#{username}@drona.com"
    @teacher.school = school 
    password = school.zip_code
    status = :ok

    unless username.nil? 
      account = @teacher.build_account :email => email, :username => username, 
                  :password => password, :password_confirmation => password
    end 

    if @teacher.save
      Yardstick.select('id, default_allotment').each do |y|
        grade = @teacher.grades.new :allotment => y.default_allotment, :yardstick_id => y.id
        status = grade.save ? :ok : :bad_request
        break if status == :bad_request
      end
      (status == :ok) ? respond_with(@teacher) : head(:bad_request)
    else
      head :bad_request
    end

  end 
 
  def show 
    render :nothing => true, :layout => 'teachers'
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
