class CoursesController < ApplicationController
  respond_to :json 

  def show 
    @course = Course.find(params[:id]) 
    respond_with @course 
  end 

  def update 
    course = Course.find params[:id] 
    status = :ok
    
    status = course.nil? ? :bad_request : 
            (course.update_attributes(params[:course]) ? :ok : :bad_request)
    head status 
  end 

  def search 
    head :ok
  end 

  def create 
   new_course = Course.new params[:course] 
   status = new_course.save ? :ok : :bad_request 
   head status
  end 

  def list
    criterion = params[:criterion]
    @courses = Course.for_klass(criterion).for_subject(criterion).in_board(criterion).all
    respond_with @courses
  end 

end
