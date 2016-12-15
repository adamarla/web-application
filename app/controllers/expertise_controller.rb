
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
  end # of method 

end # of class
