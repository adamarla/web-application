class StudentsController < ApplicationController

  def create 
    school_id = params[:student].delete :marker 
    school = School.find school_id 
    status = school.nil? ? :bad_request : :ok 

    head status if status == :bad_request 

    email = params[:student].delete :email # part of Account model
    student = Student.new params[:student]
    student.school = school 
    password = school.zip_code
    account = student.build_account :email => 'dummy@gmail.com', :password => password, 
                                    :password_confirmation => password, 
                                    :username => student.generate_username

    head (student.save ? :ok : :bad_request) 
  end 

end
