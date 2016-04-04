
class SkillsController < ApplicationController
  respond_to :json 

  def create 
    proceed = !params[:c].blank?
    if proceed 
      generic = params[:generic] || false 
      s = Skill.create chapter_id: params[:c], 
                       generic: generic
      render json: { id: s.id, path: s.sku.path }, status: :created 
    else 
      render json: { id: 0 }, status: :bad_request 
    end 
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
