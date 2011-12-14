class CoursesController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json 

  def show 
    @course = Course.find(params[:id]) 
    @syllabi = Syllabus.where(:course_id => @course.id)
    respond_with @course, @syllabi 
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

  def load 
    @course = Course.find params[:id] 
    unless @course.nil? 
      respond_with @course 
    else 
      head :bad_request 
    end 
  end 

end
