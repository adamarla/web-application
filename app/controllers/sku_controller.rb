
class SkuController < ApplicationController

  def recompiled
    path = params[:path] 
    unless path.blank?
      # path = q/[ex-id]/[q-id] OR vault/[skills|snippets]/[id]
      uid = (path =~ /^vault(.*)/).nil? ? path : path.split("/")[1..2].join("/")
      sku = Sku.where(path: uid).first 

      unless sku.nil?
        if sku.virgin
          sku.update_attribute :virgin, false 
          sku.recompute_ownership 
        else 
          sku.set_modified_on_zips
        end 
        render json: { id: sku.id }, status: :ok 
      else 
        render json: { id: 0 }, status: :bad_request 
      end 
    else
      render json: { id: 0 }, status: :bad_request 
    end 
  end 

end 
