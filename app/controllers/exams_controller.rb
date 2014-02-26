class ExamsController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!, :except => [:update_signature]
  respond_to :json

  def summary
    # students who got this exam
    @exam = Exam.find params[:id]
    head :bad_request if @exam.nil?
    # @mean = @exam.mean?
    @students = @exam.students.order(:first_name)
    @totals = @students.map{ |s| s.marks_scored_in @exam.id }
    @honest = @students.map{ |s| s.honestly_attempted? @exam.id }
    @max = @exam.quiz.total?
    @questions = @exam.quiz.subparts # subparts actually - and index ordered 
    @g_all = GradedResponse.in_exam @exam.id
  end

  def load 
    e = Exam.find params[:id]
    unless e.nil?
      render json: { a: e.path? }
    else # shouldn't happen. But if it does, then show the sample created for the parent quiz
      render json: { a: "#{e.quiz.path?}/sample" }
    end
  end

  def layout
    # Returns ordered list of questions - renderable as .tabs-left
    @exam = Exam.find params[:e]
    student_id = params[:id].blank? ? current_account.loggable_id : params[:id]

    @who = current_account.loggable_type
    unless @exam.nil?
      @subparts = Subpart.in_quiz @exam.quiz_id
      @gr = GradedResponse.of_student(student_id).in_exam @exam.id
    else
      head :bad_request 
    end
  end

  def inbox # as a verb
    ws = Exam.where(:id => params[:id]).first 

    if ws.nil?
      render json: { notify: { text: "Worksheet not found" } }, status: :ok
    else 
      ws.update_attribute :takehome, true
      render json: { notify: { 
              text: "#{ws.quiz.name} published"
            } }, status: :ok
    end
  end 

  def uninbox
    ws = Exam.where(:id => params[:id]).first 
    if ws.nil?
      render json: { notify: { text: "Worksheet not found" } }, status: :ok
    else 
      render json: { notify: { 
              text: "#{ws.quiz.name} recalled / un-published"
            } }, status: :ok
    end
  end

  def report_card
    exam = Exam.find_by_id(params[:id])
    if params[:format] == "csv"
      send_data exam.to_csv, :filename => "#{exam.quiz.name}#{exam.name}.csv", :disposition => 'attachment'
    end
  end

  # throwaway method
  def update_signature
    student_id   = params[:id]
    exam_id = params[:tp_id]
    signature    = params[:sign]

    quiz = Exam.find_by_id(exam_id).quiz
    as = Worksheet.of_student(student_id).for_exam(exam_id).first
    unless as.nil?
      if signature.length == quiz.questions.count
        as.update_attribute :signature, signature
      end
    end
    render json: "A-Ok"
  end

end
