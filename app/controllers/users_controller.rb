class UsersController < ApplicationController
  respond_to :json

  def ping 
    user = User.where(email: params[:email]).first 

    if user.nil?
      user = User.new first_name: params[:first_name], 
                      last_name: params[:last_name], 
                      email: params[:email],
                      gender: params[:gender]
      uid = user.save ? user.id : 0 
    else
      uid = user.id 
    end 

    if uid > 0 # updating something else of a previously created record
      token = params[:gcm_token] 

      unless token.blank?  
        device = Device.where(user_id: uid, gcm_token: token).first || 
                 Device.create(user_id: uid, gcm_token: token)
      else 
        device = nil 
      end 
      uid = 0 if device.nil? 
    end 
    render json: { id: uid }, status: (uid > 0 ? :ok : :internal_server_error)
  end 
end
