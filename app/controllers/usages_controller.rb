class UsagesController < ApplicationController
  respond_to :json 

  def update 
    # Update usage record unconditionally with any data sent
    # back from the phone
    # 
    # We are, of course, assuming that the user has installed 
    # the app on one phone only and hence the probability 
    # data from one phone over-writing that from another is low 

    usage = Usage.where(user_id: params[:id], date: params[:date]).first || 
             Usage.create(user_id: params[:id], date: params[:date], time_zone: params[:time_zone])

    updated = usage.update_attributes time_on_snippets: params[:time_on_snippets],
                                    time_on_questions: params[:time_on_questions], 
                                    time_on_stats: params[:time_on_stats], 
                                    num_snippets_done: params[:num_snippets_done], 
                                    num_questions_done: params[:num_questions_done]

    # [1.0+]: New JSON fields  
    unless params[:num_snippets_clicked].blank? 
      updated = usage.update_attributes num_snippets_clicked: params[:num_snippets_clicked],
                                        num_questions_clicked: params[:num_questions_clicked]
    end 

    # [1.06+] 
    unless params[:num_dropped].blank?
      updated = usage.update_attributes num_dropped: params[:num_dropped]
    end

    render json: { updated: true }, status: (updated ? :ok : :internal_server_error)
  end # of method 

  def daily 
    usages = Usage.newcomers  
    str_dates = usages.map(&:date).sort.uniq # alphabetically sorted  
    dates = str_dates.sort{ |x,y| x.to_date <=> y.to_date } # chronologically sorted 

    json = [{one: 'DATE', two: 'N_SN', three: 'N_Q', four: 'T_SN', five: 'T_Q', six: 'T_STATS', seven: 'ENGMNT' }]

    dates.each do |d| 
      u = usages.where(date: d)
      num_snippets = u.map(&:num_snippets_done).inject(:+) 
      num_questions = u.map(&:num_questions_done).inject(:+) 
      time_snippets = u.map(&:time_on_snippets).inject(:+) 
      time_questions = u.map(&:time_on_questions).inject(:+) 
      time_stats = u.map(&:time_on_stats).inject(:+) 
      engagement = "#{u.something_done.count} / #{u.count}"

      j = { one: d.to_date.strftime("%d/%m/%y"), 
            two: num_snippets, 
            three: num_questions, 
            four: time_snippets, 
            five: time_questions, 
            six: time_stats, 
            seven: engagement }

      json.push(j)

    end # of each 

    render json: json, status: :ok

  end # of method 

end # of class
