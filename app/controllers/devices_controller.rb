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
    is_math = params[:type] != "joke"

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
      # Pick a question of the day 
      if dev_mode 
        q = Question.where(uid: '1/7di/z92ua').first
        label = "Dev mode testing"
      elsif is_math  
        q = Question.where(potd: true).order(:num_potd).first 
        b = BundleQuestion.where(question_id: q.id).first 
        q.update_attribute(:num_potd, q.num_potd + 1) unless test_mode 
        label = b.name 
      else # jotd 
        j = Joke.where(disabled: false).order(:num_jotd).first
        j.update_attribute(:num_jotd, j.num_jotd + 1) unless test_mode
      end 

      # Send GCM call 
      gcm = GCM.new(api_key)

      if is_math
        payload = {
          collapse_key: 'potd', 
          time_to_live: 86390, # 10 seconds less than a single day
          data: { packet: { label: label, uid: q.uid, id: q.id, notification_id: notif_uid , type: :potd } }
        }
      else 
        payload = {
          collapse_key: 'jotd',
          data: { packet: { uid: j.uid, image: j.image, notification_id: notif_uid, type: :jotd } }
        } 
      end 

      response = gcm.send reg_ids, payload 

      unless test_mode 
        db_entry = is_math ? Potd.create(uid: notif_uid, question_id: q.id, num_sent: reg_ids.count) 
                           : Jotd.create(uid: notif_uid, joke_id: j.id, num_sent: reg_ids.count) 
      else 
        db_entry = nil 
      end 

      # Any tokens the GCM server says are invalid should be invalidated here too.
      unregistered = response[:not_registered_ids]

      unless unregistered.blank?
        Device.where(gcm_token: unregistered).map(&:invalidate)
        db_entry.update_attribute(:num_failed, unregistered.count) unless db_entry.nil?
      end 

      num_posted = reg_ids.count - unregistered.count 
    else 
      num_posted = 0 
    end 
    render json: { posted: num_posted }, status: :ok
  end 

end
