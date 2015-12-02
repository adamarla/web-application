class NotifResponseController < ApplicationController
  respond_to :json 

  def update 
    record = NotifResponse.where(category: params[:type], uid: params[:uid]).first 
    unless record.nil?
      column = params[:opened] ? :num_opened : (params[:dismissed] ? :num_dismissed : :num_received)
      record.update_attribute(column, record[column] + 1)
      render json: { updated: true }, status: :ok 
    else 
      render json: { updated: false }, status: :internal_server_error 
    end 
  end 

end
