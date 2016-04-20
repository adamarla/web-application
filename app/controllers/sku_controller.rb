
class SkuController < ApplicationController

  def recompiled
    path = params[:path] 
    unless path.blank?
      # path = q/[ex-id]/[q-id] OR vault/[skills|snippets]/[id]
      uid = (path =~ /^vault(.*)/).nil? ? path : path.split("/")[1..2].join("/")
      sku = Sku.where(path: uid).first 

      unless sku.nil?
        sku.has_svgs ? sku.set_modified_on_zips : sku.update_attribute(:has_svgs, true)
        render json: { id: sku.id }, status: :ok 
      else 
        render json: { id: 0 }, status: :bad_request 
      end 
    else
      render json: { id: 0 }, status: :bad_request 
    end 
  end 
  
  def list
    unless params[:c].blank? 
      skus = Sku.in_chapter params[:c].to_i
      response = skus.map{ |sku| 
        { 
          id: sku.stockable_id, 
          path: sku.path, 
          authorId: sku.author_id, 
          chapterId: params[:c].to_i,
          assetClass: sku.stockable_type
        } 
      }
      render json: response, status: :ok
    else
      render json: { id: 0 }, status: :bad_request 
    end 
  end

end 
