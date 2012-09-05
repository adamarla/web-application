class CalibrationsController < ApplicationController
  respond_to :json
  before_filter :authenticate_account!

  def assign
=begin
     Check that there is some scan associated with passed responses. If not, 
     then there is no point proceeding 

     params.keys = {:i => insight, :f => formulation, :c => calculation, :g => graded_response_id }
=end
    @calibration = Calibration.where :insight_id => params[:i], 
                                    :formulation_id => params[:f], 
                                    :calculation_id => params[:c]
    head :bad_request if @calibration.empty? 

    response = GradedResponse.where(:id => params[:g]).first
    response.calibrate_to @calibration.first.id

    coordinates = GradedResponse.annotations params[:clicks] 
    # Higher priority number => less importance 
    scan = "#{response.testpaper.quiz_id}-#{response.testpaper_id}/#{response.scan}"
    Delayed::Job.enqueue AnnotateScan.new(scan, coordinates), 
      :priority => 10, :run_at => Time.zone.now unless coordinates.empty?
  end 

  def explain
    response = GradedResponse.where(:id => params[:id]).first 
    head :bad_request if (response.nil? || response.calibration_id.nil?)
    @c = response.calibration
  end
  
end
