class StudentsController < ApplicationController

  def create 
    school_id = params[:student].delete :marker 
    school = School.find school_id 
    status = school.nil? ? :bad_request : :ok 

    head status if status == :bad_request 

    student = Student.new params[:student]
    student.school = school 

    head (student.save ? :ok : :bad_request) 
  end 

end
