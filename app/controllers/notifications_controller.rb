class NotificationsController < ApplicationController
  respond_to :json

  def received 
    uid = params[:notification_id]
    qid = params[:id] 

    n = Notification.where(uid: uid).first
    if n.nil?
      n = Notification.create(uid: uid, question_id: qid, num_received: 1) 
    else
      n.update_attribute(:num_received, n.num_received + 1)
    end 
    render nothing: true, status: :ok
  end 

  def opened
    n = Notification.where(uid: params[:notification_id]).first 
    # What happens if the ping for receiving notification got dropped
    # but the ping for opening comes through? 
    if n.nil? 
      n = Notification.create(uid: uid, question_id: params[:id], num_received: 1, num_opened: 1) 
    else 
      n.update_attribute(:num_opened, n.num_opened + 1)
    end 
    render nothing: true, status: :ok
  end 
end # of class 
