class SchoolsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json 

  def create 
    email = params[:school].delete :email # email is part of Account model 
    @school = School.new params[:school] 
    username = @school.generate_username 
    email = email || "#{username}@drona.com"
    zip = @school.zip_code

    @school.build_account :email => email, :username => username, 
                          :password => zip, :password_confirmation => zip

    @school.save ? respond_with(@school) : head(:bad_request) 
  end 

  def show 
    @school = School.find params[:id]
    respond_with @school
  end 

  def update 
    school = School.find params[:id] 
    status = :ok 

    unless school.nil? 
      active = params[:account][:active] == 'true' ? true : false 
      status = school.update_attributes(params[:school]) ? :ok : :bad_request
      unless status == :bad_request
        status = school.account.update_attribute(:active, active) ? :ok : :bad_request
      end 
    else 
      status = :bad_request 
    end 
    head status 
  end 

  def list 
    search_criterion = params[:criterion]
    @schools = School.state_matches(search_criterion).order(:name).all
    respond_with @schools 
  end 

  def new_student 
    school = School.find params[:id]
    return :bad_request if school.nil? 
    
    head :ok
  end 

  def unassigned_students 
    @students = Student.where(:school_id => params[:id], :study_group_id => nil).order(:first_name)
    @who_wants_to_know = current_account.nil? ? :guest : current_account.role
  end 

  def sections 
    @sections = StudyGroup.where(:school_id => params[:id]).order(:klass).order(:section)
  end 

end
