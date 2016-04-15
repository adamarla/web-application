
class ZipController < ApplicationController
  respond_to :json 

  # Only from zippify 
  def update
    # Once the zip has been re-generated, update its SHASUM 
    zip = Zip.find params[:id] 
    shasum = params[:shasum] 
    zip.update_attributes(modified: false, shasum: shasum) unless zip.nil? 
    render json: { id: params[:id] }, status: :ok
  end 

  # Only from zippify 
  def list_contents
    zip = Zip.find params[:id]
    skus = zip.skus 
    render json: { 
                    name: zip.name, 
                    id: zip.id, 
                    chapter: zip.parcel.chapter_id, 
                    type: zip.parcel.contains, 
                    skus: skus.map{ |s| { id: s.id, path: s.path } } 
                 }, status: :ok 
  end 

  # From the mobile app 
  def ping 
    zip = Zip.find params[:id] 
    render json: { id: zip.id, shasum: zip.shasum }, status: :ok
  end 


end # of class
