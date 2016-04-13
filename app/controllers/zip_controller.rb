
class ZipController < ApplicationController
  respond_to :json 

  def ping 
    zip = Zip.find params[:id] 
    render json: { id: zip.id, shasum: zip.shasum }, status: :ok
  end 

end 
