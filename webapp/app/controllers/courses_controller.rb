class CoursesController < ApplicationController
  respond_to :json 

  def show 
    @course = Course.find(params[:id]) 
    respond_with @course 
  end 

  def update 
    head :ok 
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
    @courses = Course.all
    respond_with @courses
  end 

end
