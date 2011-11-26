class SchoolsController < ApplicationController
  respond_to :json 

  def list 
    @schools = School.all 
	respond_with @schools 
  end 

end
