class ExamsController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!, :except => [:update_signature]
  respond_to :json

  def ping 
    @e = Exam.find params[:id]
  end 

  def summary
    # students who got this exam
    @exam = Exam.find params[:id]
    head :bad_request if @exam.nil?
    # @mean = @exam.mean?
    @students = @exam.students.order(:first_name)

    n = @students.count 
    @per_pg, @last_pg = pagination_layout_details n
    pg = params[:page].nil? ? 1 : params[:page].to_i
    @students = @students.page(pg).per(@per_pg)

    @totals = @students.map{ |s| s.score_in? @exam.id }
    @perceptions = @students.map{ |s| @exam.perception?(s.id) }
    @max = @exam.quiz.total?
    @questions = @exam.quiz.subparts # subparts actually - and index ordered 
    @g_all = Tryout.in_exam @exam.id
  end

  def load 
    @e = Exam.find params[:id]
  end

  def layout
    # Returns ordered list of questions - renderable as .tabs-left
    @exam = Exam.find params[:e]
    sid = params[:id].blank? ? current_account.loggable_id : params[:id]

    @who = current_account.loggable_type
    unless @exam.nil?
      @qsids = QSelection.where(quiz_id: @exam.quiz_id).order(:index)
      per_pg, @last_pg = pagination_layout_details(@qsids.count, 8)
      pg = params[:page].nil? ? 1 : params[:page].to_i
      w = Worksheet.where(student_id: sid, exam_id: @exam.id).first 

      if pg == 1 # only when the exam layout is first loaded 
        unless current_account.mimics_admin
          @who == 'Student' ? w.up_view_count(:student) : w.up_view_count(:teacher)
        end
      end 
      @qsids = @qsids.page(pg).per(per_pg)
      @gr = Tryout.where(worksheet_id: w.id)
      @criteria = Rubric.find(@exam.rubric_id?).criteria?(:all) 
      # include even those criteria that have become inactive since the time the exam was graded
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

  def pending_disputes
    eid = params[:id]
    @g = Tryout.in_exam(eid).unresolved.order(:student_id).order(:q_selection_id)
    n = @g.count 
    per_pg, @last = pagination_layout_details(n, 30)
    page = params[:page].blank? ? 1 : params[:page].to_i
    @g = @g.page(page).per(per_pg)
  end

  def resolved_disputes
    eid = params[:id]
    @g = Tryout.in_exam(eid).resolved.order(:student_id).order(:q_selection_id)
    n = @g.count 
    per_pg, @last = pagination_layout_details(n, 30)
    page = params[:page].blank? ? 1 : params[:page].to_i
    @g = @g.page(page).per(per_pg)
  end

  def report_card
    exam = Exam.find_by_id(params[:id])
    if params[:format] == "csv"
      send_data exam.to_csv, :filename => "#{exam.quiz.name}#{exam.name}.csv", :disposition => 'attachment'
    end
  end

  def deadlines
    @eid = params[:id]
    e = Exam.find @eid

    # Example params: 
    #    "deadline"=>{"submit(1i)"=>"", "submit(2i)"=>"", "submit(3i)"=>"", "regrade(1i)"=>"", "regrade(2i)"=>"", "regrade(3i)"=>""}
    d = params[:deadline].values.map(&:to_i)
    subm_m = d[1]
    rgrd_m = d[4]
    today = Date.today

    unless subm_m == 0 # month component of submission deadline not defined
      subm_d = d[2] == 0 ? 1 : d[2]
      subm_date = Date.parse("#{subm_m}/#{subm_d}")
      subm_date = subm_date > today ? subm_date : Date.parse("#{subm_d}/#{subm_m}/#{today.year + 1}")
    else
      subm_date = nil
    end

    unless rgrd_m == 0 # month component of regrade deadline not defined 
      rgrd_d = d[5] == 0 ? 1 : d[5]
      rgrd_date = Date.parse("#{rgrd_m}/#{rgrd_d}")
      rgrd_date = rgrd_date > today ? rgrd_date : Date.parse("#{rgrd_d}/#{rgrd_m}/#{today.year + 1}")
    else
      rgrd_date = nil
    end

    unless subm_date.nil?
      unless rgrd_date.nil?
        rgrd_date = (rgrd_date < subm_date) ? (subm_date + 15.days) : rgrd_date
      end
    end

    # Time to update exam object 
    e.update_attributes submit_by: subm_date, regrade_by: rgrd_date
    render json: { msg: :ok }, status: :ok
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
