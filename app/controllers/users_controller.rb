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

    token = params[:gcm_token] 
    unless (token.blank? || uid == 0) 
      device = Device.where(user_id: uid, gcm_token: token).first || 
               Device.create(user_id: uid, gcm_token: token)
    end 

    render json: { id: uid }, status: (uid > 0 ? :ok : :internal_server_error)
  end # of action  

  def csv_list 
    min_id = params[:id].blank? ? 537 : params[:id]
    users = User.where('id > ?', min_id).order(:id)
    json = users.map{ |c| { one: c.first_name, two: c.last_name, three: c.email, four: c.id } }
    json.unshift({ one: 'firstname', two: 'lastname', three: 'email', four: 'database_id' })
    render json: json, status: :ok
  end 

end # of class
