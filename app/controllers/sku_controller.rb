
class SkuController < ApplicationController

  def recompiled
    sku = Sku.with_path params[:path]

    unless sku.nil? 
      obj = sku.stockable 
      obj.update_attribute(:chapter_id, params[:c]) unless params[:c].blank?
      obj.has_svgs ? sku.tag_modified_zips : obj.update_attribute(:has_svgs, true)
      render json: { id: (obj.is_a?(Riddle) ? obj.get_id : obj.id) }, status: :ok
    else
      render json: { id: 0 }, status: :bad_request 
    end 
  end 

  def set_skills 
    sku = Sku.with_path params[:path]

    unless sku.nil?
      obj = sku.stockable 

      unless obj.is_a?(Skill) 
        ids = params[:skills].split(",").map(&:to_i).uniq
        obj.set_skills(ids) unless ids.blank?
        render json: { id: obj.get_id }, status: :ok
      else 
        render json: { id: obj.id }, status: :ok
      end 
    else 
      render json: { id: 0 }, status: :bad_request 
    end 
  end 
  
  def list 
    c = params[:c].blank? ? 0 : params[:c].to_i 
    listing = Sku.in_chapter(c) 

    response = listing.map{ |sku| obj = sku.stockable ; 
                                  { id: obj.is_a?(Skill) ? obj.id : obj.get_id, 
                                    path: sku.path,
                                    authorId: obj.examiner_id, 
                                    chapterId: c, 
                                    assetClass: obj.class.name,
                                    hasSvgs: obj.has_svgs } }

    render json: response, status: :ok
  end 

end # of class 
