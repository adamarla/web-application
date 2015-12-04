class AnalgesicsController < ApplicationController
  respond_to :json

  def create 
    # Allow creation of multiple records at the same time 
    uids = params[:uid].split(",").select{ |a| !a.empty? }
    j = uids.map{ |k| { uid: k, category: params[:type] } }
    new_records = Analgesic.create j 
    status = new_records.count == uids.count ? :ok : :internal_server_error  
    render nothing: true, status: status 
  end 

end
