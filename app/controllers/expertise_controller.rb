
class ExpertiseController < ApplicationController 
  respond_to :json 

  def update 
    # Request can come only from mobile app. Hence, we can assume 
    # that is properly formed 

    pid = params[:pid] 
    skill = params[:skill]

    e = Expertise.where(pupil_id: pid, skill_id: skill).first 
        || Expertise.create(pupil_id: pid, skill_id: skill) 

    e.update_attributes(num_tested: params[:num_tested], num_correct: params[:num_correct])
    render json: { id: e.id }, status: :ok
  end 

end 
