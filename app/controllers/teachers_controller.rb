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

    unless username.nil? 
      account = @teacher.build_account :email => email, :username => username, 
                                      :password => password, :password_confirmation => password
    end 

    @teacher.save ? respond_with(@teacher) : head(:bad_request) 
  end 
 
  def show 
    @teacher = params[:id].nil? ? current_account.loggable : 
                                  Teacher.find(params[:id])
    if @teacher.grades.empty? 
      # Create default grades for this teacher
      Yardstick.all.each { |d| 
        grade = @teacher.grades.new :yardstick_id => d.id,
                                    :allotment => d.default_allotment
        grade.save
      } 
    end 
    @grades = @teacher.grades
  end 

  def update 
    head :ok 
#    grades = params[:grades] 
#    status = :ok 
#
#    grades.each { |id, allotment|
#      grade = Grade.find(id) 
#      status = (grade && grade.update_attribute(:allotment, allotment)) ? :ok : :bad_request
#      break if status == :bad_request 
#    } 
#    head status 
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
