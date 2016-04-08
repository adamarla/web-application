
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
    render json: skills.map{ |s| { id: s.id, path: s.sku.path } }, status: :ok
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
