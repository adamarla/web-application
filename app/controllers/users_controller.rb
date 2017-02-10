class UsersController < ApplicationController
  respond_to :json

  def ping 
    user = User.where(email: params[:email]).first || 
           User.create(first_name: params[:first_name], 
                       last_name: params[:last_name],
                       email: params[:email],
                       gender: params[:gender])

    unless user.nil?
      num_invites_sent = params[:num_invites_sent].blank? ? 0 : params[:num_invites_sent] 
        
      user[:num_invites_sent] = num_invites_sent if (num_invites_sent > user.num_invites_sent)
      user[:version] = params[:app_version].to_f unless params[:app_version].blank? 
      user[:time_zone] = params[:time_zone] unless params[:time_zone].blank?
      user[:join_date] = params[:join_date] unless params[:join_date].blank?
      user.save 

      response = {} 
      response[:first_name] = user.first_name unless user.first_name.blank? 
      response[:last_name] = user.last_name unless user.last_name.blank? 
      response[:id] = user.id 

      render json: response, status: :ok
    else
      render json: { id: 0 }, status: :internal_server_error 
    end 
  end 

  def csv_list 
    min_id = params[:id].blank? ? 537 : params[:id]
    users = User.newcomers.where('id > ?', min_d).order(:id)

    json = users.map{ |c| { one: c.first_name, two: c.last_name, three: c.email, four: c.id } }
    json.unshift({ one: 'firstname', two: 'lastname', three: 'email', four: 'database_id' })
    render json: json, status: :ok
  end 

end # of class
