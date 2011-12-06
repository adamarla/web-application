class SyllabiController < ApplicationController
  respond_to :json 

  def update 
    options = params[:syllabi] 
    #course_id = options.nil? ? nil : options.delete(:course_id)
    course_id = params[:course_id].nil? ? nil : params[:course_id][:marker] 
    course = course_id.nil? ? nil : Course.find(course_id) 

    status = course.nil? ? :bad_request : course.update_syllabus(params[:syllabi]) 
    head status 
  end 

  def show 
    course = params[:course_id] 
    @syllabi = Syllabus.where(:course_id => course).all 

    respond_with @syllabi
  end 
end
