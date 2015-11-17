class DevicesController < ApplicationController
  respond_to :json
  require 'gcm'

  def create 
    device = Device.where(gcm_token: params[:gcm_token]).first 
    if device.nil? 
      device = Device.new(gcm_token: params[:gcm_token], pupil_id: params[:pupil_id])
      status = device.save ? :ok : :internal_server_error 
    else 
      status = :ok
    end 
    # send some JSON back in response. Otherwise, Response.ErrorListener
    # will get called in Android even when everything went ok.
    render json: { pupil_id: params[:pupil_id] }, status: status 
  end 

  def post_potd
    dev_mode = params[:mode] == "dev" 
    test_mode = !params[:id].blank?
    potd_id = Date.today.strftime("%b %d, %Y")

    if dev_mode 
      api_key = "AIzaSyCuk-OPh2qoB4b9mlAYUeLAJdMlVowk2hY" # dev key 
    else 
      api_key = "AIzaSyCFH3hFqMdGP1dyqSkEyZgrpxHJwbKru68" # release key 
    end 

    # Ensure there is someone to send POTDs to
    devices = Device.where(live: true)
    send_to = test_mode ? devices.where(pupil_id: params[:id])  : devices
    reg_ids = send_to.map(&:gcm_token) 

    unless reg_ids.blank?
      # Pick a question of the day 
      if dev_mode 
        qid = 1098 
        quid = "1/7di/z92ua" 
        label = "Dev mode testing"
      else 
        q = Question.where(potd: true).order(:num_potd).first 
        b = BundleQuestion.where(question_id: q.id).first 
        q.update_attribute(:num_potd, q.num_potd + 1) unless test_mode 
        label = b.name 
        qid = q.id 
        quid = q.uid 
      end 

      # Send GCM call 
      gcm = GCM.new(api_key)
      payload = {
        collapse_key: 'potd', 
        time_to_live: 86390, # 10 seconds less than a single day
        data: { packet: { label: label, uid: quid, id: qid, notification_id: potd_id } }
      }

      response = gcm.send reg_ids, payload 
      problem = test_mode ? nil : Potd.create(uid: potd_id, question_id: qid) 

      # Any tokens the GCM server says are invalid should be invalidated here too.
      unregistered = response[:not_registered_ids]

      unless unregistered.blank?
        Device.where(gcm_token: unregistered).map(&:invalidate)
        problem.update_attribute(:num_failed, unregistered.count) unless problem.nil?
      end 

      num_posted = reg_ids.count - unregistered.count 
    else 
      num_posted = 0 
    end 
    render json: { posted: num_posted }, status: :ok
  end 

end
