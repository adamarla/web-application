class PupilsController < ApplicationController
  respond_to :json

  def create_or_update 
    render json: { status: :ok }, status: :ok
  end 

end
