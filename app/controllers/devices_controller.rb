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
    #api_key = "AIzaSyCuk-OPh2qoB4b9mlAYUeLAJdMlVowk2hY" # dev key 
    api_key = "AIzaSyCFH3hFqMdGP1dyqSkEyZgrpxHJwbKru68" # release key 

    # Ensure there is someone to send notifications to
    reg_ids = Device.where(live: true).map(&:gcm_token)

    unless reg_ids.blank?
      # Pick a question of the day 
      q = Question.where(potd: true).order(:num_potd).first 
      b = BundleQuestion.where(question_id: q.id).first 
      q.update_attribute(:num_potd, q.num_potd + 1)

      # Send GCM call 
      gcm = GCM.new(api_key)
      payload = {
        collapse_key: 'potd', 
        time_to_live: 86400, # a single day
        data: { packet: { label: b.name, uid: q.uid, id: q.id } }
      }
      response = gcm.send reg_ids, payload 

      # Any tokens the GCM server says are invalid should be invalidated here too.
      unless response[:not_registered_ids].blank?
        Device.where(gcm_token: response[:not_registered_ids]).map(&:invalidate)
      end 
    end 
    render nothing: true, status: :ok
  end 

end
