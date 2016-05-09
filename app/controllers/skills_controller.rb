
class SkillsController < ApplicationController
  respond_to :json 

  def create 

    proceed = !(params[:c].blank? || params[:e].blank?)
    if proceed
      examiner = Examiner.find params[:e]
      if examiner.is_admin
        cid = params[:c] || Chapter.generic.id 
        s = Skill.create(chapter_id: cid, examiner_id: examiner.id)
        render json: { id: s.id, path: s.sku.path }, status: :created 
      else
        render json: { id: 0 }, status: :bad_request
      end
    else
      render json: { id: 0 }, status: :bad_request
    end
  end 

  def list 
    cid = params[:c] || Chapter.generic.id 
    skills = Skill.where(chapter_id: cid) 

    # Should also return the minimal set of zips that need to be 
    # downloaded to get said skills 

    sku_ids = Sku.where(stockable_id: skills.map(&:id), stockable_type: Skill.name).map(&:id)
    zip_ids = Inventory.where(sku_id: sku_ids).map(&:zip_id).uniq

    render json: { 
                    skills: skills.map{ |s| { id: s.id, path: s.sku.path,
                        authorId: s.examiner_id, chapterId: cid.to_i, assetClass: "Skill" } },
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
