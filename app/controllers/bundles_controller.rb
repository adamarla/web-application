class BundlesController < ApplicationController
  respond_to :json

  def ping 
    response = {} 

    unless params[:tag].blank?
      bundles = Bundle.with_uid_like(params[:tag]).not_empty 
    else 
      bundles = params[:type].blank? ? 
          Bundle.where(uid: params.values) : 
          Bundle.where('auto_download = ? AND signature IS NOT ?', true, nil)
    end 
   
    bundles.each do |b|
      response[b.uid] = b.signature 
    end 

    # From version 2.22 onwards, we also send back the fastest bingo 
    # for each question in the bundle. 
    # Format: response[:fastest_bingo] = [{question_id, name, time}, ..... ]

    response[:fastest_bingo] = []
    bundles.each do |b| 
      bingos = b.questions.map(&:fastest_bingo).select{ |x| !x.nil? }
      bingos.each do |bingo| 
        response[:fastest_bingo] << { question_id: bingo.question_id, 
                                      name: bingo.pupil.name, 
                                      time: bingo.time_to_bingo }
      end 
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
