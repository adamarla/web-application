class GradesController < ApplicationController
  respond_to :json
  before_filter :authenticate_account!

  def update
    grade = Grade.where(:yardstick_id => params[:id], :teacher_id => params[:teacher_id]).first
    head :bad_request if grade.nil?
    if grade.update_attribute :allotment, params[:grade][:allotment]
      render :json => { :status => "Updated!" }, :status => :ok
    else
      render :json => { :status => "Oops" }, :status => :bad_request
    end
  end

  def assign
    yardsticks = Yardstick.order(:default_allotment).select{ |a| !a.mcq }.map(&:id)
    given = params[:grade].map{ |k,v| { k.to_i => v.blank? || v.to_i < 0 ? nil : v.to_i } }

    given.each do |h|
      id = h.keys.first 
      grade = h[id]
      y = grade.nil? ? nil : yardsticks[grade]
      next if y.nil? 

      response = GradedResponse.find id 
      response.assign_grade y # will assign grade and calculate marks as per teacher's marking scheme
    end

    response_ids = params[:grade].keys.map(&:to_i).select{ |e| e > 0 }
    scan = GradedResponse.where(:id => response_ids).map(&:scan).uniq.first

    head :bad_request if scan.nil? 

    clicks = params[:clicks]
    clicks = clicks.split '|'
    coordinates = [] 

    clicks.each do |pt|
      next if pt.blank? 
      pt = pt.split(',').map(&:to_i)
      coordinates.push({:x => pt[0], :y => pt[1]})
    end

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['annotate_scan']}" 
    response = SavonClient.request :wsdl, :annotate_scan do
      soap.body = {
        :scanId => scan, 
        :coordinates => coordinates
      }
    end 
    error = response[:annotate_scan_response][:error]
    if error.nil?
      render( :json => { :status => "Done"}, :status => :ok )
    else
      render( :json => { :status => "Oops!"}, :status => :bad_request )
    end 

  end 

end
