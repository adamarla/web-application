class BundlesController < ApplicationController
  respond_to :json

  def ping 
    ids = params.values
    response = {} 
    Bundle.where(uid: ids).each do |zip|
      response[zip.uid] = zip.signature 
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