class SyllabiController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json 

  def update 
    options = params[:syllabi] 
    course = Course.find params[:id]
    head (course.nil? ? :bad_request : course.update_syllabus(params[:syllabi]))
  end 

  def show 
    course = params[:course_id] 
    @syllabi = Syllabus.where(:course_id => course).all 

    respond_with @syllabi
  end 
end
