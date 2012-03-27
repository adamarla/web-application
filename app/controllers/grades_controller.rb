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
    # 1. Check that there is some scan associated with passed responses. If not, 
    # then there is no point proceeding 

    response_ids = params[:grade].keys.map(&:to_i).select{ |e| e > 0 }
    scan = GradedResponse.where(:id => response_ids).map(&:scan).uniq.first
    render(:json => { :status => "No Scan!" }, :status => :bad_request) if scan.nil?

    # 2. Scan present => continue with grade capture
    given = params[:grade].map{ |k,v| { k.to_i => v.blank? || v.to_i < 0 ? nil : v.to_i } }

    given.each do |g|
      id = g.keys.first # graded_response_id 
      grade = g[id].nil? ? nil : g[id]
      next if grade.nil? 

      response = GradedResponse.find id 
      response.assign_grade grade # will assign grade and calculate marks as per teacher's marking scheme
    end
    
    # 3. Send coordinates of any clicks on the scan so that it can be annotated 
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
      render( :json => { :status => "Annotation Failed!"}, :status => :bad_request )
    end 

  end 

end
