class DevicesController < ApplicationController
  respond_to :json

  def create 
    device = Device.new(gcm_token: params[:gcm_token], pupil_id: params[:pupil_id])
    status = device.save ? :ok : :internal_server_error 
    render nothing: true, status: status 
  end 
end
