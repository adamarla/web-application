class PupilsController < ApplicationController
  respond_to :json

  def ping 
    pupil = Pupil.where(email: params[:email]).first 

    if pupil.nil?
      pupil = Pupil.new first_name: params[:first_name], 
                      last_name: params[:last_name], 
                      email: params[:email],
                      gender: params[:gender]
      pid = pupil.save ? pupil.id : 0 
    else
      pid = pupil.id 
    end 

    unless params[:id].blank? # updating something else of a previously created record
      unless params[:gcm_token].blank? 
        device = Device.where(pupil_id: params[:id], gcm_token: params[:gcm_token]).first 
        device = Device.create(pupil_id: params[:id], gcm_token: params[:gcm_token]) if device.nil?
      else 
        device = nil 
      end 
      pid = 0 if device.nil? 
    end 
    render json: { id: pid }, status: (pid > 0 ? :ok : :internal_server_error)
  end 
end
