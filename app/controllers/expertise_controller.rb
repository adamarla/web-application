
class ExpertiseController < ApplicationController 
  respond_to :json 

  def ping 
    # Request can come only from the mobile app 
    # Request would be for returning expertise numbers for passed user

    uid = params[:uid]
    e = Expertise.where(user_id: uid)

    render json: e.map{ |x| { 
          skill_id: x.skill_id, 
          path: x.skill.sku.path,
          chapter_id: x.skill.chapter_id, 
          num_tested: x.num_tested,
          num_correct: x.num_correct, 
          weighted_tested: x.weighted_tested, 
          weighted_correct: x.weighted_correct
        }
      }, status: :ok 
    
  end 

  def update 
    # Request can come only from mobile app. Hence, we can assume 
    # that it is properly formed  

    uid = params[:uid] 
    sk_id = params[:skill]

    e = Expertise.where(user_id: uid, skill_id: sk_id).first || 
        Expertise.create(user_id: uid, skill_id: sk_id) 

    skill = e.skill 
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
              skill_id: skill.id,  
              chapter_id: skill.chapter_id, 
              path: skill.sku.path, 
              num_tested: e.num_tested, 
              num_correct: e.num_correct,
              weighted_tested: e.weighted_tested, 
              weighted_correct: e.weighted_correct
            }, status: :ok

  end # of method 

end # of class
