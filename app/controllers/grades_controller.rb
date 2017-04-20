
class GradesController < ApplicationController
  respond_to :json 

  def list 
    response = Grade.all.map{ |g| { id: g.id, name: g.name } }
    render json: response, status: :ok 
  end 

end 
