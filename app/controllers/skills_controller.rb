
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

  def ping 
    ids = params[:ids].delete('[]').split(',').map(&:to_i)
    skills = Skill.where(id: ids) 
    json = skills.map{ |s| { id: s.id, average_proficiency: s.avg_proficiency } }
    render json: json, status: :ok
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

  def all
    json = Skill.all.map{ |s| {
      id: s.id, path: s.sku.path, 
        authorId: s.examiner_id, chapterId: s.chapter_id, assetClass: "Skill" }
    }
    render json: json, status: :ok
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

  def set_chapter
    s = Skill.find params[:id]
    unless s.nil?
      s.update_attribute :chapter_id, params[:c].to_i unless params[:c].nil?

      render json: { id: s.id }, status: :ok
    else
      render json: { id: 0 }, status: :bad_request
    end
  end # of action 

  def missing 
    ids = params[:ids].delete('[]').split(',').map(&:to_i)

    j = Skill.where(id: ids, has_svgs: true).map(&:id) 
    sku_ids = Sku.where(stockable_id: j).map(&:id) 
    zip_ids = Inventory.where(sku_id: sku_ids).map(&:zip_id).uniq 
    zips = Zip.where(id: zip_ids).where('shasum IS NOT ?', nil) 

    render json: zips.map{ |z| { 
                                 id: z.id, 
                                 name: z.name, 
                                 shasum: z.shasum, 
                                 chapter_id: z.parcel.chapter_id,  
                                 type: z.parcel.contains,
                                 parcel_id: z.parcel.id
                               }
                          }, status: :ok
  end # of method  

  def revaluate 
    Skill.all.map(&:revaluate_proficiency)
    render json: { done: :ok }, status: :ok
  end 

end # of class 
