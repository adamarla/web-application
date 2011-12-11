class StudentsController < ApplicationController
  before_filter :authenticate_account!

  def create 
    school_id = params[:student].delete :marker 
    school = School.find school_id 
    status = school.nil? ? :bad_request : :ok 

    head status if status == :bad_request 
    
    student = Student.new params[:student]
    username = student.generate_username
    email = params[:student].delete(:email) || "#{username}@drona.com"
    student.school = school 
    password = school.zip_code

    unless username.blank?
      account = student.build_account :username => username, :email => email,  
                                      :password => password, :password_confirmation => password
    end 
    head (student.save ? :ok : :bad_request) 
  end 

end
