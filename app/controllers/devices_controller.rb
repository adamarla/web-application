class DevicesController < ApplicationController
  respond_to :json

  def create 
    device = Device.new(gcm_token: params[:gcm_token], pupil_id: params[:pupil_id])
    status = device.save ? :ok : :internal_server_error 
    # send some JSON back in response. Otherwise, Response.ErrorListener
    # will get called in Android even when everything went ok.
    render json: { pupil_id: params[:pupil_id] }, status: status 
  end 
end
