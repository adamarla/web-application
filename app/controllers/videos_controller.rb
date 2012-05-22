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

  def load
    @video = Video.where(:id => params[:id])
    head :bad_request if @video.nil?
  end 

  def howtos
    @videos = Video.where(:active => true).order(:index)
  end

end
