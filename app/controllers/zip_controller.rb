
class ZipController < ApplicationController
  respond_to :json 

  def update
    # Once the zip has been re-generated, update its SHASUM 
    zip = Zip.find params[:id] 
    shasum = params[:shasum] 
    zip.update_attributes(modified: false, shasum: shasum) unless zip.nil? 
    render json: { id: params[:id] }, status: :ok
  end 

  def ping 
    zip = Zip.find params[:id] 
    render json: { id: zip.id, shasum: zip.shasum }, status: :ok
  end 

  def list_contents
    zip = Zip.find params[:id]
    skus = zip.skus 
    render json: { 
                    name: zip.name, id: zip.id, 
                    skus: skus.map{ |s| { id: s.id, type: s.stockable_type, path: s.path } } 
                 }, status: :ok 
  end 

end # of class
