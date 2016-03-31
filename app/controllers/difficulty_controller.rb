
class DifficultyController < ApplicationController
  respond_to :json 

  def list 
    response = Difficulty.order(:level).map{ |d| { id: d.level, name: d.name } }
    render json: response, status: :ok 
  end 

end 
