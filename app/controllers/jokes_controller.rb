class JokesController < ApplicationController
  respond_to :json

  def create 
    image = params[:type] == "PNG"
    j = Joke.new uid: params[:uid], image: image
    status = j.save ? :ok : :internal_server_error 
    render nothing: true, status: status 
  end 

end
