class BundlesController < ApplicationController
  respond_to :json

  def ping 
    @bundles = Bundle.where(uid: params[:id])
    # response goes to mobile-app 
  end 

  def update 
    b = Bundle.where(uid: params[:id]).first 
    unless b.nil?
      shasum = params[:signature]
      b.update_attribute(:signature, shasum) unless shasum.blank?
    end 
    render json: { status: :ok }, status: :ok
    # response goes to Linode 
  end 
end
