class VideosController < ApplicationController
  before_filter :authenticate_account!, :only => :create
  respond_to :json
  
  def play
    type = params[:type]
    id = params[:id]

    video = type == "Lesson" ? Lesson.find(id).video : Question.find(id).video
    unless video.nil?
      render json: { uid: video.uid }, status: :ok
    else
      render json: { status: :failed }, status: :bad_request
    end
  end 

end
