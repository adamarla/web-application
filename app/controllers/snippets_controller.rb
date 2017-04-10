
class SnippetsController < ApplicationController 
  respond_to :json 

  def create 
    proceed = !(params[:e].blank? || params[:c].blank?)
    if proceed 
      snip = Snippet.create(author_id: params[:e], chapter_id: params[:c])
      render json: { id: snip.id, path: snip.sku.path }, status: :created 
    else 
      render json: { id: 0 }, status: :bad_request 
    end 
  end 
  
  def list 
    listing = params[:c].blank? ? Snippet.where('id > ?', 0) : Snippet.where(chapter_id: params[:c].to_i)
    tested_on = params[:skills].blank? ? [] : params[:skills].map(&:to_i)
    skills = tested_on.blank? ? [] : Skill.where(id: tested_on).map(&:uid) 
    listing = skills.blank? ? listing : listing.tagged_with(skills, any: true, on: :skills)

    # For some reason, and unlike in question/list, we were also 
    # returning the minimal set of Zips needed to download the 
    # the required snippets. 
    # Hence, for the sake of backward compatibility, we will do the 
    # same here too. 

    skus = Sku.where(stockable_id: listing.map(&:id), stockable_type: "Riddle").map(&:id) 
    zips = Inventory.where(sku_id: skus).map(&:zip_id).uniq 

    render json: { 
                    snippets: listing.map{ |s| { id: s.get_id, path: s.sku.path } }, 
                    zips: Zips.where(id: zips).map(&:path)
                 }, status: :ok
  end 

  def set_chapter
    # In the new Riddle table, Snippet.id >= 2000 whereas Snippet.original_id <= 600   

    id = params[:id].blank? ? 0 : params[:id].to_i 
    s = Snippet.where('id = ? OR original_id = ?', id, id).first 

    unless s.nil?
      s.update_attribute :chapter_id, params[:c].to_i unless params[:c].nil?
      render json: { id: s.get_id }, status: :ok
    else
      render json: { id: 0 }, status: :bad_request
    end
  end # of action 

end # of controller  

