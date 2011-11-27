class SchoolsController < ApplicationController
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
    @schools = School.all 
    respond_with @schools 
  end 

end
