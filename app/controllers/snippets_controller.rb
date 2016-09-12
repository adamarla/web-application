
class SnippetsController < ApplicationController 
  respond_to :json 

  def create 
    proceed = !(params[:e].blank? || params[:c].blank?)
    if proceed 
      snip = Snippet.create(examiner_id: params[:e], chapter_id: params[:c])
      render json: { id: snip.id, path: snip.sku.path }, status: :created 
    else 
      render json: { id: 0 }, status: :bad_request 
    end 
  end 
  
  def list 
    unless params[:c].blank? 
      snippets = params[:skill].blank? ? 
                      Snippet.where(chapter_id: params[:c]) :
                      Snippet.with_skills(params[:skill]).where(chapter_id: params[:c])

      unless snippets.blank? 
        # We should also return the minimal set of zips that need 
        # to be downloaded to get said snippets

        sku_ids = Sku.where(stockable_id: snippets.map(&:id), stockable_type: Snippet.name).map(&:id)
        zip_ids = Inventory.where(sku_id: sku_ids).map(&:zip_id).uniq 

        render json: { 
                        snippets: snippets.map{ |s| { id: s.id, path: s.sku.path } },
                        zips: Zip.where(id: zip_ids).map(&:path)
                     }, status: :ok

      else # no snippets  
        render json: { snippets: [], zips: [] }, status: :ok
      end 

    else # no chapter specified 
      render json: { snippets: [], zips: [] }, status: :bad_request 
    end 
  end 

end # of controller  
