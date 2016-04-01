
class DifficultyController < ApplicationController
  respond_to :json 

  def list 
    response = Difficulty.order(:level).map{ |d| { id: d.id, name: "#{d.name.titleize} (#{d.meaning})" } }
    render json: response, status: :ok 
  end 

end 
