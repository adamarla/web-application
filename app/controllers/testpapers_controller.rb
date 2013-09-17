class TestpapersController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!
  respond_to :json

  def summary
    # students who got this testpaper
    @ws = Testpaper.find params[:id]
    head :bad_request if @ws.nil?
    # @mean = @ws.mean?
    @students = @ws.students.order(:first_name)
    @totals = @students.map{ |s| s.marks_scored_in @ws.id }
    @honest = @students.map{ |s| s.honestly_attempted? @ws.id }
    @max = @ws.quiz.total?
    @questions = @ws.quiz.subparts # subparts actually - and index ordered 
    @g_all = GradedResponse.in_testpaper @ws.id
  end

  def load 
    @testpaper = Testpaper.find params[:id]
    @uid = encrypt(@testpaper.id, 7)
  end

  def preview # the answer-key actually
    @ws_id = params[:id].to_i

    if params[:student].blank?
      @relative_index = nil
    else
      sid = params[:student].to_i
      student_ids = AnswerSheet.where(testpaper_id: @ws_id).map(&:student_id).sort
      @relative_index = student_ids.index sid
    end

    ws = Testpaper.find @ws_id 
    @quiz = ws.nil? ? nil : Quiz.where(:id => ws.quiz_id).first
  end 

  def layout
    # Returns ordered list of questions - renderable as .tabs-left
    @ws = Testpaper.find params[:ws]
    student_id = params[:id].blank? ? current_account.loggable_id : params[:id]

    @who = current_account.loggable_type
    unless @ws.nil?
      @subparts = Subpart.in_quiz @ws.quiz_id
      @gr = GradedResponse.of_student(student_id).in_testpaper @ws.id
      @root_folder = @ws.legacy_record? ? "#{@ws.quiz_id}-#{@ws.id}" : "nothing"
    else
      head :bad_request 
    end
  end

  def inbox # as a verb
    ws = Testpaper.where(:id => params[:id]).first 

    if ws.nil?
      render :json => { :notify => { :text => "Worksheet not found" } }, :status => :ok
    else 
      ws.update_attribute :takehome, true
      render :json => { :notify => { 
              :text => "#{ws.quiz.name} published"
            } }, :status => :ok
    end
  end 

  def uninbox
    ws = Testpaper.where(:id => params[:id]).first 
    if ws.nil?
      render :json => { :notify => { :text => "Worksheet not found" } }, :status => :ok
    else 
      render :json => { :notify => { 
              :text => "#{ws.quiz.name} recalled / un-published"
            } }, :status => :ok
    end
  end

end
