class StudentsController < ApplicationController

  def create 
    school_id = params[:student].delete :marker 
    school = School.find school_id 
    status = school.nil? ? :bad_request : :ok 

    head status if status == :bad_request 
    
    # E-mails are not strictly required and hence 'email' could be nil
    email = params[:student].delete :email # part of Account model

    student = Student.new params[:student]
    student.school = school 
    password = school.zip_code
    username = student.generate_username

    unless username.blank?
      unless email.blank? 
        account = student.build_account :username => username, :password => password, 
                                        :email => email, :password_confirmation => password
      else 
        account = student.build_account :username => username, :password => password, 
                                        :password_confirmation => password
      end 
    end 
    head (student.save ? :ok : :bad_request) 
  end 

end
