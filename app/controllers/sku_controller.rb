
class SkuController < ApplicationController

  def recompiled
    sku = Sku.with_path params[:path]

    unless sku.nil?
      # Set the chapter_id extracted from the XML 
      sku.set_chapter_id(params[:c]) unless params[:c].blank?
      sku.has_svgs ? sku.set_modified_on_zips : sku.update_attribute(:has_svgs, true)
      render json: { id: sku.id }, status: :ok 
    else 
      render json: { id: 0 }, status: :bad_request 
    end 
  end 

  def set_skills 
    sku = Sku.with_path params[:path]

    unless sku.nil?
      sids = param[:skills].split(",").map(&:to_i).uniq 
      sku.stockable.set_skills(sids) unless sids.blank?
      render json: { id: sku.id } , status: :ok
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
    else
      response = []
      assetTypes = ["Skill", "Snippet", "Question"]
      assetTypes.map{ |aType|
        assetClass = Object.const_get(aType)
        response += assetClass.all.map{ |s|
          {
            id: s.id, 
            path: s.sku.nil? ? s.path : s.sku.path,
            authorId: s.examiner_id,
            chapterId: s.chapter_id.nil? ? 0 : s.chapter_id, 
            assetClass: aType }
          }
      }
    end 
    render json: response, status: :ok
  end

end 
