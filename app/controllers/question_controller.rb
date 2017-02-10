
class QuestionController < ApplicationController
  respond_to :json

  def create 
    proceed = !(params[:e].blank? || params[:c].blank?)
    if proceed 
      language = params[:lang] || Language.named('english') 
      difficulty = params[:d] || Difficulty.named('medium')
      q = Question.create examiner_id: params[:e], 
                          chapter_id: params[:c],
                          language_id: language, 
                          difficulty: difficulty
      render json: { id: q.id, path: q.sku.path }, status: :created
    else 
      render json: {id: 0 }, status: :bad_request
    end 
  end 

  def list 
    listing = params[:c].blank? ? Question.where('id > ?', 0) : Question.where(chapter_id: params[:c].to_i)
    tested_on = params[:skills].blank? ? [] : params[:skills].map(&:to_i)
    skills = tested_on.blank? ? [] : Skill.where(id: tested_on).map(&:uid) 
    listing = skills.blank? ? listing : listing.tagged_with(skills, any: true, on: :skills)

    render json: listing.map{ |q| { id: q.get_id, path: q.sku.path } }, status: :ok
  end 

  def set_chapter 
    # In the new Riddle table, Question.id >= 2000 whereas Question.original_id <= 1400 

    id = params[:id].blank? ? 0 : params[:id].to_i
    q = Question.where('id = ? OR original_id = ?', id, id).first 

    unless q.nil? 
      q.update_attribute :chapter_id, params[:c].to_i unless params[:c].nil?
      render json: { id: q.get_id }, status: :ok
    else 
      render json: { id: 0 }, status: :bad_request 
    end 
  end # of action 

end # of class  
