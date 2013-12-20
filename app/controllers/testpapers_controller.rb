class TestpapersController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!, :except => [:update_signature]
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

  def layout
    # Returns ordered list of questions - renderable as .tabs-left
    @ws = Testpaper.find params[:ws]
    student_id = params[:id].blank? ? current_account.loggable_id : params[:id]

    @who = current_account.loggable_type
    unless @ws.nil?
      @subparts = Subpart.in_quiz @ws.quiz_id
      @gr = GradedResponse.of_student(student_id).in_testpaper @ws.id
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

  def report_card
    testpaper = Testpaper.find_by_id(params[:id])
    if params[:format] == "csv"
      send_data testpaper.to_csv, :filename => "#{testpaper.quiz.name}#{testpaper.name}.csv", :disposition => 'attachment'
    end
  end

  # throwaway method
  def update_signature
    student_id   = params[:id]
    testpaper_id = params[:tp_id]
    signature    = params[:sign]

    quiz = Testpaper.find_by_id(testpaper_id).quiz
    as = Worksheet.of_student(student_id).for_testpaper(testpaper_id).first
    unless as.nil?
      if signature.length == quiz.questions.count
        as.update_attribute :signature, signature
      end
    end
    render :json => "A-Ok"
  end

end
