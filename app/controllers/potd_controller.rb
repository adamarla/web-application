class PotdController < ApplicationController
  respond_to :json

  def update 
    potd = Potd.where(uid: params[:potd_id]).first
    unless potd.nil?
      target = params[:opened] ? :num_opened : :num_received
      potd.update_attribute(target, potd[target] + 1)
    end 
    render json: { updated: true }, status: :ok 
  end 

end # of class 
