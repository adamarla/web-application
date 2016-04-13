
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
    # render json: { name: zip.name, id: zip.id, paths: skus.map(&:path) }, status: :ok
    render json: { 
                    name: zip.name, id: zip.id, 
                    skus: skus.map{ |s| { id: s.id, type: s.stockable_type, path: s.path } } 
                 }, status: :ok 
  end 

  def update_zip
    # Once the zip has been re-generated, update its SHASUM 
    zip = Zip.find params[:id] 
    shasum = params[:shasum] 
    zip.update_attributes(modified: false, shasum: shasum) unless zip.nil? 
    render json: { id: params[:id] }, status: :ok
  end 

=begin
  The logic for when to start downloading the next zip because 
  the student is close to finishing the ones already on his device 
  resides in the mobile app. Here, we just do the calculations (given 
  the attempted SKU IDs) and tell the mobile which Zip to download
=end 

  def next_zip 
    p = Parcel.find params[:parcel] # should never be nil
    zip = (p.contains == Skill.name) ? p.zips.first : p.next_zip( params[:sku_ids] || [] ) 

    unless zip.nil? 
      render json: { id: zip.id, name: zip.name, shasum: zip.shasum, chapter_id: p.chapter_id, type: p.contains } , status: :ok
    else 
      render json: { id: 0 }, status: :bad_request 
    end 
  end 

end # of class 
