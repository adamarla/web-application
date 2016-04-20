
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
    assets = []
    json = []
    unless params[:c].nil?
      chapter_id = params[:c].to_i
      questions = Question.where(chapter_id: chapter_id)
      skills = Skill.where(chapter_id: chapter_id)
      snippets = Snippet.where(skill_id: skills.map(&:id))

      assets = questions + skills + snippets
      json = assets.map{ |a|
        {id: a.id, 
         path: a.sku.path, 
         authorId: a.sku.stockable_type == "Skill" ? 1 : a.examiner_id, 
         chapterId: a.sku.stockable_type == "Snippet" ?
           a.skill.chapter_id : a.chapter_id,
         assetClass: a.sku.stockable_type}
      }
      render json: json, status: :ok
    else
      render json: { id: 0 }, status: :bad_request
    end
  end

end 
