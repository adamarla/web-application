class SektionsController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!, except: [:monthly_audit]
  respond_to :json 

  def ping
    @sk = Sektion.find params[:id]
  end

  def create 
    p = params[:new]

    start_mnth = p['smonth(2i)'].to_i # the 2i bit is due to simple_form 
    duration = p[:duration].to_i
    renew = p[:renew] == "1" ? false : true
    renew_immediate = p[:renew] == "2"

    today = Date.today 

    # 'year' should be such that 'today' either (descending order of preference)
    #    1. already lies in the specified time range 
    #    2. will soon lie in the specified range 
    # 'today' should NOT lie outside the range when the sektion is created

    start_date = Date.civil(today.year, start_mnth, 1)
    end_date = (start_date + duration.months).yesterday

    if start_date > today # try same month in previous year
      a = Date.civil(today.year - 1, start_mnth, 1)
      b = (a + duration.months).yesterday
      if b > today
        start_date = a 
        end_date = b
      end
    elsif end_date < today # start sektion in next year
      start_date = Date.civil(today.year + 1, start_mnth, 1)
      end_date = (start_date + duration.months).yesterday
    end

    # current_account.loggable should be / would be a teacher. 
    # If not, then its an unexpected - and big - problem
    @sk = current_account.loggable.sektions.build name: p[:name],
                                                 start_date: start_date, end_date: end_date,
                                                 auto_renew: renew, auto_renew_immediate: renew_immediate
    unless @sk.save
      render json: { notify: { text: @sk.errors[:name] } }, status: :ok
    end
  end 

  def monthly_audit
    Sektion.monthly_audit
    render json: { status: :audited }, status: :ok
  end

  def update 
    sektion = Sektion.find params[:id]
    editable = (sektion && (sektion.teacher_id == current_account.loggable_id))

    if editable
      student_ids = sektion.student_ids
      @removed = params[:checked].keys.map(&:to_i)
      retain = student_ids - @removed
      sektion.student_ids = retain
    else
      render json: { 
        notify: { 
          text: "Update failed", 
          subtext: "Cannot update someone else's section" 
        } }, status: :ok
    end
  end 

  def students 
    @sektion = Sektion.find params[:id]

    @students = @sektion.students.order(:first_name)

    @context = params[:context]

    if @context == 'exb'
      eids = Exam.where(quiz_id: params[:quiz]).map(&:id)
      past_takers = Worksheet.where(exam_id: eids).map(&:student_id).uniq
      @disabled = @students.map(&:id) & past_takers
    else
      @disabled = []
    end
  end 

  def proficiency
    sektion = Sektion.find params[:of]
    @topic = Topic.find params[:in]
    head :bad_request if (sektion.nil? || @topic.nil?)

    teacher = current_account.loggable

    quizzes = Quiz.where(:teacher_id => teacher.id) # all quizzes by teacher
    quizzes = quizzes.blank? ? Quiz.where(:id => 318) : quizzes # 318 = "A Demo Quiz" 

    selections = QSelection.where(:quiz_id => quizzes.map(&:id)).on_topic(@topic.id) # all questions on topic
    responses = Tryout.where(:q_selection_id => selections.map(&:id).uniq).graded # all responses to those questions

    subparts = Subpart.where(:question_id => selections.map(&:question_id).uniq)
    @avg = (subparts.map(&:marks).inject(:+) / subparts.count.to_f).round(2)
    @db_avg = @topic.benchmark

    students = sektion.students
    n = students.count 
    per_pg, @last = pagination_layout_details(n)
    pg = params[:page].blank? ? 1 : params[:page].to_i
    @students = students.page(pg).per(per_pg).order(:first_name)
    
    @proficiency = students.map do |s|
      graded = responses.where(student_id: s.id)
      unless graded.empty?
        # total = Subpart.where(:id => graded.map(&:subpart_id)).map(&:marks).inject(:+)
        total = graded.map(&:subpart).map(&:marks).inject(:+) # takes care of the case when a question is repeated 
        scored = graded.map(&:marks).inject(:+)
        {id: s.id, score: (scored / total.to_f).round(2)}
      else
        { id: s.id, score: -1 }
      end
    end 
  end # of method

  def preview_names
    names = params[:add][:names]
    @lines = names.split("\r\n").select{ |m| !m.blank? }
  end

  def enroll_named_students
    sk = params[:id].blank? ? nil : Sektion.find(params[:id])

    unless sk.nil?
      students = params[:names].values.map(&:strip).map(&:titleize)
      new_student_ids = [] 

      for m in students
        s = Student.new(name: m, shell: true)
        #username = username_for s, :student
        #a = s.build_account email: "#{username}@drona.com", password: '123456', password_confirmation: '123456'
        new_student_ids.push(s.id) if s.save
      end

      unless new_student_ids.blank?
        enrolled = sk.student_ids 
        sk.student_ids = (enrolled + new_student_ids).uniq 
        render json: { notify: { title: "#{students.count} students added to group" } }, status: :ok
      else
        render json: { notify: { title: "No students added to group" } }, status: :ok
      end
    else # sektion not found!
      render json: { notify: { title: "Group not found!" } }, status: :ok
    end 
  end

  def ping_for_phones
    ids = params[:checked].keys
    @students = Student.where(id: ids).order(:first_name)
  end 

  def update_phones
    a = params[:phone].select{ |j,k| !k.blank? }
    a.each do |k,v| 
      s = Student.find k.to_i
      s.set_phone v
    end 
    render json: { status: :ok }, status: :ok
  end 

end
