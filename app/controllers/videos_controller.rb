class VideosController < ApplicationController
  before_filter :authenticate_account!, :only => :create
  respond_to :json
  
  def create
    video = Video.new params[:video]
    if video.save
      render :json => { :status => 'Done' }, :status => :ok
    else
      render :json => { :status => 'Oops' }, :status => :bad_request
    end
  end

  def list
    restricted = params[:restricted].blank? ? true : false
    @videos = Video.where(:restricted => restricted).order(:created_at)
  end

  def howtos
  end

end
