class PotdController < ApplicationController
  respond_to :json

  def update 
    record = NotifResponse.where(uid: params[:potd_id], category: "potd").first  
    unless record.nil?
      column = params[:opened] ? :num_opened : (params[:dismissed] ? :num_dismissed : :num_received)
      record.update_attribute(column, record[column] + 1)
    end 
    render json: { updated: true }, status: :ok 
  end 

end # of class 
