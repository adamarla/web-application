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

  def explain
    response = GradedResponse.where(:id => params[:id]).first 
    head :bad_request if (response.nil? || response.grade_id.nil?)
    @c = response.grade.calibration
  end

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

    # 3. Send coordinates of any clicks on the scan so that it can be annotated 
    clicks = params[:clicks]
    coordinates = [] 

    tokens = clicks.split('_').select{ |m| !m.empty? }
    # Caveat: If there were 5 clicks, then we would have 10 elements in the token
    # But we need to ignore the last two - 9 and 10 - because together they form just a 
    # point-click - whereas what we need are pairs of clicks to draw rectangles with 

    tokens.each_slice(2).each_slice(2).select{ |m| m.first != m.last }.each do |pairs| # array of arrays
      pairs.each do |pt|
        coordinates.push({ :x => pt.first.to_i - X_CORRECTION, :y => pt.last.to_i })
      end
    end

    # Higher priority number => less importance 
    Delayed::Job.enqueue AnnotateScan.new(response.scan, coordinates), 
      :priority => 10, :run_at => Time.zone.now unless coordinates.empty?
  end 
  
  X_CORRECTION = 16

end
