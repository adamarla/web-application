
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

=begin
  def set_skills 
    q = Question.find params[:id]
    unless q.nil? 
      # Set  skills. If blank, then will result in removal of all skills 
      q.set_skills( params[:skills].map(&:to_i) ) unless params[:skills].nil?

      # Set the chapter - if specified. Ensure language and difficulty 
      # of the question are also set - if not already so. 
      q.update_attribute :chapter_id, params[:c].to_i unless params[:c].nil?

      render json: { id: q.id }, status: :ok
    else 
      render json: { id: 0 }, status: :bad_request 
    end 
  end # of action 
=end

  def list 
    skill_ids = params[:skills].blank? ? [] : params[:skills].map(&:to_i)

    unless skill_ids.blank?
      skills = Skill.where(id: skill_ids).map(&:uid) 
      ques = Question.tagged_with(skills, any: true, on: :skills)
    else 
      ques = Question.where('id > ?', 0) # all questions 
    end 

    ques = ques.where(chapter_id: params[:c].to_i) unless params[:c].blank?
    render json: ques.map{ |q| {id: q.id, path: q.path } } , status: :ok  

  end # of action 

end # of class  
