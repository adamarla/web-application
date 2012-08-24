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
=begin
     Check that there is some scan associated with passed responses. If not, 
     then there is no point proceeding 

     params.keys = {:i => insight, :f => formulation, :c => calculation, :g => graded_response_id }
=end
    calibration = Calibration.where :insight_id => params[:i], 
                                    :formulation_id => params[:f], 
                                    :calculation_id => params[:c]
    head :bad_request if calibration.empty? 

    response = GradedResponse.where(:id => params[:g]).first
    response.calibrate_to calibration.first.id

    # 3. Send coordinates of any clicks on the scan so that it can be annotated 
    clicks = params[:clicks]
    clicks = clicks.split '|'
    coordinates = [] 

    clicks.each do |pt|
      next if pt.blank? 
      pt = pt.split(',').map(&:to_i)
      coordinates.push({:x => pt[0]-X_CORRECTION, :y => pt[1]})
    end

    # Higher priority number => less importance 
    Delayed::Job.enqueue AnnotateScan.new(scan, coordinates), :priority => 10, :run_at => Time.zone.now unless coordinates.empty?
    render( :json => { :status => "Done"}, :status => :ok )
  end 
  
  X_CORRECTION = 16

end
