class DevicesController < ApplicationController
  respond_to :json
  require 'gcm'

  def create 
    device = Device.new(gcm_token: params[:gcm_token], pupil_id: params[:pupil_id])
    status = device.save ? :ok : :internal_server_error 
    # send some JSON back in response. Otherwise, Response.ErrorListener
    # will get called in Android even when everything went ok.
    render json: { pupil_id: params[:pupil_id] }, status: status 
  end 

  def post_potd
    # api_key = "AIzaSyDN5sSLkuo6Rv6NoDDnpuSZxNroYumG-_Y"
    api_key = "AIzaSyCuk-OPh2qoB4b9mlAYUeLAJdMlVowk2hY" # dev key 
    # api_key = "AIzaSyCFH3hFqMdGP1dyqSkEyZgrpxHJwbKru68" # release key 


    gcm = GCM.new(api_key)
    reg_ids = Device.where(live: true).map(&:gcm_token)
    payload = {
#      notification: {
#        body: 'Tuesday @ 11:40am', 
#        title: 'GCM development', 
#        icon: "@mipmap/think"
#      }, 
      collapse_key: 'potd', 
      time_to_live: 86400, # a single day
      data: { message: "Hello Dude!" }
    }
    response = gcm.send reg_ids, payload 

    # Any tokens the GCM server says are invalid should be invalidated here too.
    unless response[:not_registered_ids].blank?
      Device.where(gcm_token: response[:not_registered_ids]).map(&:invalidate)
    end 
    render nothing: true, status: :ok
  end 

end
