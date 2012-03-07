class SyllabiController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json 

  def update 
    course = Course.find params[:id]
    unless course.nil?
      course.update_syllabus(params[:difficulty]) ? 
                            render(:json => { :status => "Updated" }, :status => :ok) :
                            render(:json => { :status => "Oops !" }, :status => :bad_request)
    else
      render :json => { :status => "Record not found!" }, :status => :bad_request
    end
  end 

  def show 
    course = params[:course_id] 
    @syllabi = Syllabus.where(:course_id => course).all 
  end 

end
