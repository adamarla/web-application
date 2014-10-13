class StabsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def ping 
    # params[:op] = check, grade, answer, solution, proofread or nil 
    s = params[:s].to_i 
    q = params[:q].to_i 
    v = params[:v].to_i 

    stab = Stab.where(question_id: q, student_id: s, version: v).first
    response = {} 

    unless params[:op].blank? 
      stab = stab.nil? ? Stab.create(student_id: s, question_id: q, version: v) : stab
      case params[:op]
        when 'answer'
          stab.charge :answer 
          response[:codex] = stab.version
        when 'solution' 
          stab.charge :solution 
          response[:version] = stab.version
      end 
      # return menu_state AFTER applying any charges 
      response[:menu] = stab.menu_state 
      response[:gredits] = stab.student.gredits 
      response[:stab] = stab.id 
    else # options button clicked in mobile app
      # Do NOT create a stab IF just the Options button clicked. 
      # Create a stab only if the student engages by clicking on a menu option
      balance = Student.find(s).gredits
      menu_state = nil 

      if stab.nil?
        ques = Question.find q
        menu_state = {
          check: true, 
          grade: true, 
          answer: (balance >= ques.price_to_see_answer?), 
          solution: (balance >= ques.price_to_see_solution?), 
          proofread: true
        } 
      else
        menu_state = stab.menu_state 
      end 
      response = { menu: menu_state, gredits: balance } 
    end # of else 
    render json: response, status: :ok
  end 

  def dates
    # Render the list of unique dates (oldest first) for
    # which there are stabs (for puzzles or questions). 
    # Obviously, they must have an accompanying scan

    type = params[:type]
    cnd = Stab.where(examiner_id: current_account.loggable_id).with_scan

    a = type.blank? ? cnd.ungraded : (type == 'graded' ? cnd.graded : cnd)
    @dates = a.map(&:uid).uniq
  end 

  def dated
    uid = params[:uid].to_i
    lgid = current_account.loggable_id
    @is_examiner = current_account.loggable_type == 'Examiner'

    if @is_examiner
      @stabs = Stab.where(uid: uid).assigned_to(lgid)
      @stabs = params[:type].blank? ? @stabs.ungraded : (params[:type] == 'graded' ? @stabs.graded : @stabs)
      @stabs = @stabs.order(:question_id, :version)
    else 
      @stabs = Stab.where(uid: uid, student_id: lgid).graded.order(:question_id)
    end 
  end 

  def grade 
    # We get the stab from the kaagaz-IDs
    kgz_ids  = params[:kgz].keys.map(&:to_i)
    stab_id = Kaagaz.where(id: kgz_ids).map(&:stab_id).first # should be the same stab_id for all!
    
    all_good = Kaagaz.annotate params[:kgz]
    if all_good 
      stab = Stab.find stab_id 
      qlt = params[:stab][:quality].to_i
      stab.update_attribute :quality, qlt
    end 
    render json: { status: (all_good ? :success : :failed) }, status: :ok
  end 

  def graded
    # by default, graded stabs for the currently logged in student.
    # Else, stabs graded by passed examiner
    
    if params[:e].blank?
      @stabs = Stab.graded.where(student_id: current_account.loggable_id)
    else
      @stabs = Stab.graded.assigned_to params[:e].to_i
    end 
    @uids = @stabs.map(&:uid).sort.uniq
  end 

  def load 
    @stb = Stab.find params[:id] 
    @kgz = @stb.kaagaz
  end 

  def bell_curve
    stb = Stab.find params[:id]
    qid = stb.question_id 
    render json: { bell: Stab.bell_curve(qid), rating: Stab.quality_defn(stb.quality) }, status: :ok
  end 

end
