
class ExpertiseController < ApplicationController 
  respond_to :json 

  def update 
    # Request can come only from mobile app. Hence, we can assume 
    # that is properly formed 

    uid = params[:uid] 
    skill = params[:skill]

    e = Expertise.where(user_id: uid, skill_id: skill).first || 
        Expertise.create(user_id: uid, skill_id: skill) 

    was_synced = params[:synced] 

    if was_synced
      if params[:num_tested] > e.num_tested 
        [:num_tested, :num_correct, :weighted_tested, :weighted_correct].each do |column|
          e[column] = params[column]
        end 
        e.save 
      end 
    else # new data from a new source 
      [:num_tested, :num_correct, :weighted_tested, :weighted_correct].each do |column|
        e[column] += params[column]
      end 
      e.save 
    end 

    render json: { 
              id: e.id, 
              num_tested: e.num_tested, 
              num_correct: e.num_correct,
              weighted_tested: e.weighted_tested, 
              weighted_correct: e.weighted_correct
            }, status: :ok

  end # of method 

end # of class
