class SyllabiController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json 

  def update 
    course = Course.find params[:id]
    head (course.nil? ? :bad_request : course.update_syllabus(params[:difficulty]))
  end 

  def show 
    course = params[:course_id] 
    @syllabi = Syllabus.where(:course_id => course).all 
  end 

end
