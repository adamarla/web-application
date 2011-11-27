class SchoolsController < ApplicationController
  respond_to :json 

  def create 
    head :ok
  end 

  def list 
    @schools = School.all 
	respond_with @schools 
  end 

end
