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
        status = school.save ? :ok : :bad
      else
        status = :bad 
      end 
    else 
      status = :bad
    end 
    head status 
  end 

  def list 
    @schools = School.all 
    respond_with @schools 
  end 

end
