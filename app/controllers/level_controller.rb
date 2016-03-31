
class LevelController < ApplicationController
  respond_to :json 

  def list 
    response = Level.all.map{ |l| { id: l.id, name: l.name } }
    render json: response, status: :ok 
  end 

end 
