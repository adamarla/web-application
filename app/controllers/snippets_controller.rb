
class SnippetsController < ApplicationController 
  respond_to :json 

  def create 
    proceed = !(params[:e].blank? || params[:sk].blank?)
    if proceed 
      snip = Snippet.create examiner_id: params[:e], 
                            skill_id: params[:sk]

      render json: { id: snip.id, path: snip.sku.path }, status: :created 
    else 
      render json: { id: 0 }, status: :bad_request 
    end 
  end 



end 
