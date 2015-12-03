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

  def post
    dev_mode = params[:mode] == "dev" 
    test_mode = !params[:id].blank?
    notif_uid = Date.today.strftime("%b %d, %Y")
    is_math = params[:type] != "humor"

    if dev_mode 
      api_key = "AIzaSyCuk-OPh2qoB4b9mlAYUeLAJdMlVowk2hY" # dev key 
    else 
      api_key = "AIzaSyCFH3hFqMdGP1dyqSkEyZgrpxHJwbKru68" # release key 
    end 

    # Ensure there is someone to send POTDs to

    live_devices = Device.where(live: true)
    dnc_list = live_devices.where(pupil_id: [3,4,7,18,116]) # dnc = do-not-call
    send_to = test_mode ? live_devices.where(pupil_id: params[:id])  : live_devices - dnc_list
    reg_ids = send_to.map(&:gcm_token) 

    unless reg_ids.blank?

      if is_math # POTD  
        if dev_mode 
          parent = Question.where(uid: '1/7di/z92ua').first 
          label = "Dev mode testing"
        else 
          parent = Question.where(potd: true).order(:num_potd).first 
          b = BundleQuestion.where(question_id: parent.id).first 
          parent.update_attribute(:num_potd, parent.num_potd + 1) unless test_mode 
          label = b.name 
        end 

        # GCM payload 
        payload = {
          collapse_key: 'potd', 
          time_to_live: 86390, # 10 seconds less than a single day
          data: { packet: { label: label, uid: parent.uid, id: parent.id, notification_id: notif_uid , type: :potd } }
        }
      else # Humor  
        parent = Joke.where(disabled: false).order(:num_shown).first 
        parent.update_attribute(:num_shown, parent.num_shown + 1) unless test_mode 

        # GCM payload 
        payload = {
          collapse_key: 'humor',
          data: { packet: { uid: parent.uid, image: parent.image, notification_id: notif_uid, type: :humor } }
        } 
      end 

      # Send GCM call 
      gcm = GCM.new(api_key)
      response = gcm.send reg_ids, payload 

      unless test_mode 
        type = params[:type] || "potd"
        record = NotifResponse.create(category: type, uid: notif_uid, parent_id: parent.id, num_sent: reg_ids.count) 
      else 
        record = nil 
      end 

      # Any tokens the GCM server says are invalid should be invalidated here too.
      unregistered = response[:not_registered_ids]

      unless unregistered.blank?
        Device.where(gcm_token: unregistered).map(&:invalidate)
        record.update_attribute(:num_failed, unregistered.count) unless record.nil?
      end 

      num_posted = reg_ids.count - unregistered.count 
    else 
      num_posted = 0 
    end 
    render json: { posted: num_posted }, status: :ok
  end 

end
