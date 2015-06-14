class PupilsController < ApplicationController
  respond_to :json

  def ping 
    pupil = Pupil.where(email: params[:email]).first 

    if pupil.nil?
      pupil = Pupil.new first_name: params[:first_name], 
                      last_name: params[:last_name], 
                      email: params[:email],
                      gender: params[:gender]
      id = pupil.save ? pupil.id : 0 
      render json: { id: id }, status: :ok 
    else
      render json: { id: pupil.id }, status: :ok
    end 
  end 
end
