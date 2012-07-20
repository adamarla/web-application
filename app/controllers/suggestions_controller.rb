class SuggestionsController < ApplicationController

  def block_db_slots
    m = params[:num_slots]

    m.keys.each do |n|
      n_slots = m[n].to_i
      s_id = n.to_i
      Delayed::Job.enqueue BlockDbSlots.new(n_slots, s_id), :priority => 0, :run_at => Time.zone.now unless n_slots < 1
    end
    render :json => { :status => 'done' }, :status => :ok
  end

end # of class 
