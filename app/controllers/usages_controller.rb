class UsagesController < ApplicationController
  respond_to :json 

  def update 
    # Update usage record unconditionally with any data sent
    # back from the phone
    # 
    # We are, of course, assuming that the user has installed 
    # the app on one phone only and hence the probability 
    # data from one phone over-writing that from another is low 

    # [2.08+]: Dates stored as integers (eg. 20111227) and not as strings (eg. Dec 27, 2011)
    day = params[:date]
    day = day.to_date.to_s.gsub("-","").to_i if day.is_a?(String)

    usage = Usage.where(user_id: params[:id], date: day).first || Usage.create(user_id: params[:id], date: day)
    updated = usage.update_attributes time_on_snippets: params[:time_on_snippets],
                                    time_on_questions: params[:time_on_questions], 
                                    time_on_stats: params[:time_on_stats], 
                                    num_snippets_done: params[:num_snippets_done], 
                                    num_questions_done: params[:num_questions_done]

    others_to_update = {} 

    # [1.0+]: New JSON fields  
    unless params[:num_snippets_clicked].blank? 
      others_to_update[:num_snippets_clicked] = params[:num_snippets_clicked]
      others_to_update[:num_questions_clicked] = params[:num_questions_clicked]
    end 

    # [1.06+] 
    unless params[:num_dropped].blank?
      others_to_update[:num_dropped] = params[:num_dropped] 
    end

    # [2.10+]
    unless params[:num_stats_loaded].blank?
      others_to_update[:num_stats_loaded] = params[:num_stats_loaded]
    end 

    # [pre-2.71]: Time zone stored in User model - not Usage model 
    unless params[:time_zone].blank? 
      user = User.find params[:id]
      user.update_attribute(:time_zone, params[:time_zone]) if user.time_zone.blank?
    end 

    updated = usage.update_attributes others_to_update
    render json: { updated: true }, status: (updated ? :ok : :internal_server_error)
  end # of method 

  def daily 
    usages = Usage.newcomers  
    dates = usages.map(&:date).sort.uniq

    unless params[:last].blank? 
      today = Date.today 
      end_date = today.to_s.gsub("-","").to_i
      start_date = (today - params[:last].to_i.days).to_s.gsub("-","").to_i
      dates = dates.select{ |x| x >= start_date && x <= end_date }.sort
    end 

    # Prepare the JSON response 
    json = [{one: 'DATE', two: 'N_SN', three: 'N_Q', four: 'T_SN', five: 'T_Q', six: 'T_STATS', seven: 'ENGMNT' }]
    dates.each do |d| 
      u = usages.where(date: d)
      num_snippets = u.map(&:num_snippets_done).inject(:+) 
      num_questions = u.map(&:num_questions_done).inject(:+) 
      time_snippets = u.map(&:time_on_snippets).inject(:+) 
      time_questions = u.map(&:time_on_questions).inject(:+) 
      time_stats = u.map(&:time_on_stats).inject(:+) 

      # engagement = "#{u.something_done.count} / #{u.count}"
      engagement = "#{u.average_time_solving.round(2)}/#{u.something_done.count}/#{u.count}" 

      j = { one: d.to_s.to_date.strftime("%d/%m/%y"), 
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

  def by_user

    # epoch = "01/09/2016"
    start_date = Date::strptime(params["input_date"], "%d/%m/%Y")

    count = 0
    json = []
    User.where('created_at > (?)', start_date).each do |u|
      usages = Usage.where(user_id: u.id)
      if (usages.count == 0)
        next
      end
      num_snippets = usages.map(&:num_snippets_done).inject(:+) 
      num_questions = usages.map(&:num_questions_done).inject(:+) 
      time_snippets = usages.map(&:time_on_snippets).inject(:+) 
      time_questions = usages.map(&:time_on_questions).inject(:+) 
      time_stats = usages.map(&:time_on_stats).inject(:+) 

      days = usages.count
      span = days
      with_dates = usages.select{|u| u.date != 0}
      if (with_dates.count > 1)
          minmax = with_dates.map(&:date).minmax
          earliest = Date.parse(minmax[0].to_s)
          # earliest = Date.parse(with_dates.minimum(:date).to_s)
          latest = Date.parse(minmax[1].to_s)
          # latest = Date.parse(with_dates.maximum(:date).to_s)
          span = (latest - earliest).to_i
      end

      if (num_snippets + num_questions > 0 && span > 0)
        json.push({
          id: u.id,
          ns: num_snippets,
          nq: num_questions,
          ts: time_snippets,
          tq: time_questions,
          tt: time_stats,
          da: days,
          sp: span
        })
      end
      count = count + 1
    end # of each
    render json: {data: json, total: count}, status: :ok
  end # of method

end # of class
