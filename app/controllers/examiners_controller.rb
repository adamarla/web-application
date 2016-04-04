
class ExaminersController < ApplicationController
  respond_to :json 

  def block_db_slots
    examiner = Examiner.find params[:id]
    unless examiner.nil? 
      slots = examiner.block_db_slots
      render json: { notify: { text: "10 slots blocked" } }, status: :ok 
    else 
      render json: { notify: { text: "No such examiner" } }, status: :ok
    end 
  end

  def slot_for_question
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

  def slot_for_skill
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

  def slot_for_snippet
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
