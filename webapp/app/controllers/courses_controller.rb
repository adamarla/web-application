class CoursesController < ApplicationController
  respond_to :json 

  def show 
    @course = Course.find(params[:id]) 
    respond_with @course 
  end 

  def update 
    head :ok 
  end 
end
