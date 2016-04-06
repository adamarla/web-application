
class ParcelsController < ApplicationController
	respond_to :json 

=begin
  The following controller actions are meant to be called from 
  within a bash-script (zippify) *only*

  Plus, they should be called in the order defined below 
=end 

  def list_modified_parcels 
    modified = Parcel.select(&:modified?)
    render json: { id: modified.map(&:id) }, status: :ok
  end 

	def list_modified_zips  
    id = params[:id] 
    zips = Zip.where(parcel_id: id, modified: true)
    render json: { id: zips.map(&:id) }, status: :ok
	end 

  def list_zip_contents
    zip = Zip.find params[:id]
    skus = zip.skus 
    render json: { name: zip.name, id: zip.id, paths: skus.map(&:path) }, status: :ok
  end 

  def update_zip
    # Once the zip has been re-generated, update its SHASUM 
    zip = Zip.find params[:id] 
    shasum = params[:shasum] 
    zip.update_attributes(modified: false, shasum: shasum) unless zip.nil? 
    render json: { id: params[:id] }, status: :ok
  end 

end 
