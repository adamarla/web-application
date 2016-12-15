
class ExpertiseController < ApplicationController 
  respond_to :json 

  def ping 
    # Request can come only from the mobile app 
    # Returns proficiency numbers for given user. Ignores any skills 
    # in params[:ignore]

    uid = params[:uid]
    ignore = params[:ignore].blank? ? [] : params[:ignore].delete('[]').split(',').map(&:to_i)
    e = ignore.empty? ? Expertise.where(user_id: uid) : Expertise.where(user_id: uid).where('skill_id NOT IN (?)', ignore)

    render json: e.map(&:decompile), status: :ok
=begin
    render json: e.map{ |x| { 
          skill_id: x.skill_id, 
          chapter_id: x.skill.chapter_id, 
          num_tested: x.num_tested,
          num_correct: x.num_correct, 
          weighted_tested: x.weighted_tested, 
          weighted_correct: x.weighted_correct,
          avg_proficiency: x.skill.avg_proficiency
        }
      }, status: :ok 
=end
  end # of method  

  def update 
    # Request can come only from mobile app. Hence, we can assume 
    # that it is properly formed  

    uid = params[:uid] 
    sk_id = params[:skill]

    e = Expertise.where(user_id: uid, skill_id: sk_id).first || 
        Expertise.create(user_id: uid, skill_id: sk_id) 

    if params[:synced]
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

    render json: e.decompile, status: :ok
=begin
    render json: { 
              skill_id: skill.id,  
              chapter_id: skill.chapter_id, 
              num_tested: e.num_tested, 
              num_correct: e.num_correct,
              weighted_tested: e.weighted_tested, 
              weighted_correct: e.weighted_correct
            }, status: :ok
=end
  end # of method 

end # of class
