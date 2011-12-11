class SchoolsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json 

  def create 
    email = params[:school].delete :email # email is part of Account model 

    unless (email.nil? || email.empty?) 
      school = School.new params[:school]
      zip = school.zip_code 
      status = :ok 

      unless zip.nil? 
        school.build_account :email => email, :password => zip, :password_confirmation => zip 
        status = school.save ? :ok : :bad_request
      else
        status = :bad_request 
      end 
    else 
      status = :bad_request
    end 
    head status 
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

  def unmapped_students 
    @students = Student.where(:school_id => params[:id], :study_group_id => nil)
  end 

  def sections 
    @sections = StudyGroup.where(:school_id => params[:id]).order(:klass).order(:section)
  end 

end
