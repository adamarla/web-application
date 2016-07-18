class DevicesController < ApplicationController
  respond_to :json
  require 'gcm'

  def create 
    device = Device.where(gcm_token: params[:gcm_token]).first 
    if device.nil? 
      device = Device.new(gcm_token: params[:gcm_token], user_id: params[:user_id])
      status = device.save ? :ok : :internal_server_error 
    else 
      status = :ok
    end 
    # send some JSON back in response. Otherwise, Response.ErrorListener
    # will get called in Android even when everything went ok.
    render json: { user_id: params[:user_id] }, status: status 
  end 

  def post
    dev_mode = params[:mode] == "dev" 
    targetted = !params[:id].blank?
    notif_uid = Date.today.strftime("%a %b %d, %Y")
    is_potd = params[:type] != "analgesic"

    if dev_mode 
      # api_key = "AIzaSyCuk-OPh2qoB4b9mlAYUeLAJdMlVowk2hY" # dev key 

      api_key = "AIzaSyBJefZMgFWpVOhj2CSJ8eNlwwXtn6czTQM" # dev-key 
      send_to = Device.where(user_id: 1, live: false)
    else 
      # api_key = "AIzaSyCFH3hFqMdGP1dyqSkEyZgrpxHJwbKru68" 

      api_key = "AIzaSyBEeZDj8wlLAWtKefAzmQfkzmau_XQKY-w" # release-key
      live_devices = Device.where(live: true)
      dnc_list = live_devices.where(user_id: [3,4,7,18,116]) # dnc = do-not-call
      send_to = targetted ? live_devices.where(user_id: params[:id])  : live_devices - dnc_list
    end 

    reg_ids = send_to.map(&:gcm_token) 
    unless reg_ids.blank?

      if is_potd # POTD  
        parent = params[:question_id].blank? ? nil : Question.find(params[:question_id])

        if dev_mode 
          parent = parent || Question.where(uid: '1/7di/z92ua').first 
          label = "Dev mode testing"
        else 
          if parent.nil? 
            potds = Question.where(potd: true) 
            min = potds.map(&:num_potd).min
            parent = potds.where(num_potd: min).order(:examiner_id).first 
          end 
          b = BundleQuestion.where(question_id: parent.id).first 
          parent.update_attribute(:num_potd, parent.num_potd + 1) unless targetted 
          label = b.name 
        end 

        # GCM payload 
        payload = {
          collapse_key: 'potd', 
          time_to_live: 172790, # 10 seconds less than two days 
          data: { packet: { label: label, uid: (parent.nil? ? "1/7di/z92ua" : parent.uid), 
            id: (parent.nil? ? 1098: parent.id), notification_id: notif_uid , type: :potd } }
        }
      else # Humor  
        parent = Analgesic.where(disabled: false).order(:num_shown).first 
        parent.update_attribute(:num_shown, parent.num_shown + 1) unless targetted 

        # GCM payload 
        payload = {
          collapse_key: parent.category,
          data: { packet: { uid: parent.uid, notification_id: notif_uid, type: parent.category } }
        } 
      end 

      # Send GCM call 
      gcm = GCM.new(api_key)
      response = gcm.send reg_ids, payload 

      unless targetted 
        type = parent[:category] || "potd"
        record = NotifResponse.create(category: type, uid: notif_uid, parent_id: parent.id, num_sent: reg_ids.count) 
      else 
        record = nil 
      end 

      # Any tokens the GCM server says are invalid should be invalidated here too.
      unregistered = response[:not_registered_ids]

      unless unregistered.blank?
        unrgd = Device.where(gcm_token: unregistered)

        unrgd.map(&:invalidate)
        record.update_attribute(:num_failed, unregistered.count) unless record.nil?

        # Send a mail to self with summary of unregistered users 
        fuckers = User.where(id: unrgd.map(&:user_id).uniq)
        Mailbot.app_dropoffs(fuckers).deliver
      end 

      num_posted = reg_ids.count - unregistered.count 
    else 
      num_posted = 0 
    end 
    render json: { posted: num_posted }, status: :ok
  end 

end
