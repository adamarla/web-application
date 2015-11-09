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

    # Ensure there is someone to send POTDs to
    devices = Device.where(live: true)
    test_mode = !params[:pupil].blank?
    send_to = test_mode ? devices.where(pupil_id: params[:pupil])  : devices
    reg_ids = send_to.map(&:gcm_token) 

    unless reg_ids.blank?
      # Pick a question of the day 
      q = Question.where(potd: true).order(:num_potd).first 
      b = BundleQuestion.where(question_id: q.id).first 
      q.update_attribute(:num_potd, q.num_potd + 1) unless test_mode 
      potd_id = Date.today.strftime("%b %d, %Y")

      # Send GCM call 
      gcm = GCM.new(api_key)
      payload = {
        collapse_key: 'potd', 
        time_to_live: 86390, # 10 seconds less than a single day
        data: { packet: { label: b.name, uid: q.uid, id: q.id, notification_id: potd_id } } # release 
        # data: { packet: { label: "Monday blues", uid: "1/5di/pugih", id: 1081, notification_id: potd_id } } # dev 
      }
      response = gcm.send reg_ids, payload 
      Potd.create(uid: potd_id, question_id: q.id) unless test_mode # release 
      # Potd.create(uid: potd_id, question_id: 1081) # dev 

      # Any tokens the GCM server says are invalid should be invalidated here too.
      unless response[:not_registered_ids].blank?
        Device.where(gcm_token: response[:not_registered_ids]).map(&:invalidate)
      end 
    end 
    render json: { posted: true }, status: :ok
  end 

end
