class BundlesController < ApplicationController
  respond_to :json

  def ping 
    response = {} 

    bundles = params[:type].blank? ? 
        Bundle.where(uid: params.values) : 
        Bundle.where('auto_download = ? AND signature IS NOT ?', true, nil)
   
    bundles.each do |b|
      response[b.uid] = b.signature 
    end 
    render json: response, status: :ok
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

  def questions
    b = Bundle.where(uid: params["bundle_id"]).first
    unless b.nil?
      @bqs = b.bundle_questions
    else
      @bqs = []
    end
  end

  def fetch_all
    @bundles = Bundle.all
  end

end
