
class SkillsController < ApplicationController
  respond_to :json 

  def create 
    cid = params[:c] || Chapter.generic.id 
    s = Skill.create chapter_id: cid 
    render json: { id: s.id, path: s.sku.path }, status: :created 
  end 

  def list 
    cid = params[:c] || Chapter.generic.id 
    skills = Skill.where(chapter_id: cid) 

    # Should also return the minimal set of zips that need to be 
    # downloaded to get said skills 

    sku_ids = Sku.where(stockable_id: skills.map(&:id), stockable_type: Skill.name).map(&:id)
    zip_ids = Inventory.where(sku_id: sku_ids).map(&:zip_id).uniq

    render json: { 
                    skills: skills.map{ |s| { id: s.id, path: s.sku.path },
                    zips: Zip.where(id: zip_ids).map(&:path)
                 }, status: :ok
  end 

  def update 
    proceed = !(params[:id].blank? || params[:c].blank?)
    if proceed 
      skill = Skill.find params[:id]
      skill.update_attribute :chapter_id, params[:c]
      render json: { id: skill.id, path: skill.sku.path }, status: :ok
    else 
      render json: { id: 0 }, status: :bad_request 
    end 

  end 

end 
