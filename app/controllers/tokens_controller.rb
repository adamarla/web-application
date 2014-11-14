class TokensController < ApplicationController
  respond_to :json

  def create
    account = Account.where(email: params[:email].downcase).first
    if account.nil?
      status = 204 # no content, check in other system
      json = { :message => "Check in other system" }
    elsif !account.valid_password?(params[:password])
      status = 404 
      json = { :message => "Invalid password" }
    else
      account.ensure_authentication_token!
      status = 200 
      case account.loggable_type
        when "Student"
          student = account.loggable
          ws = Worksheet.of_student(student.id)
          name = student.first_name
          worksheets = get_worksheets(ws)
        when "Teacher"
          name = Teacher.find_by_id(id).first_name
        when "Examiner"
          name = Examiner.find_by_id(id).first_name
      end
      account.update_attribute :mobile, params[:signature]

      potd = Puzzle.of_the_day.question
      json = { 
        :token => account.authentication_token, 
        :email => account.email,
        :name  => name,
        :id    => account.loggable.id,
        :bal   => student.gredits,
        :enrl  => student.sektions.count > 0,
        :topics=> get_topics(),
        :pzl   => "#{potd.topic_id}.#{potd.id}"
      }
    end
    render status: status, json: json
  end

  def destroy
    @account = Account.find_by_authentication_token(params[:id])
    if @account.nil?
      status = 404 
      json = { :message => "Invalid Token" }
    else
      @account.reset_authentication_token!
      status = 200 
      json = { :token => params[:id] }
    end
    render status: status, json: json
  end

  def verify
    account = Account.find_by_email(params[:email].downcase)
    if account.nil?
      status = 401 
      json = { :message => "Invalid email" }
    elsif account.authentication_token != params[:token]
      status = 404 
      json = { :message => "Not Authorized" }
    else 
      potd = Puzzle.of_the_day.question
      student = account.loggable
      ws = Worksheet.of_student(student.id)
      status = 200
      json = { 
        :token => account.authentication_token, 
        :email => account.email,
        :name  => student.first_name,
        :id    => account.loggable.id,
        :bal   => student.gredits,
        :enrl  => student.sektions.count > 0,
        :topics=> get_topics(),
        :pzl   => "#{potd.topic_id}.#{potd.id}"
      }
    end
    render status: status, json: json
  end

  def refresh_qs
    account = Account.find_by_email(params[:email].downcase)
    if account.nil?
      status = 401
      json = { :message => "Invalid email" }
    elsif account.authentication_token != params[:token]
      status = 404
      json = { :message => "Not Authorized" }
    elsif account.loggable_type != "Student"
      status = 404
      json = { :message => "Invalid Account Type" }
    else
      student = account.loggable
      status = 200

      marker = params[:marker].nil? ? 0 : params[:marker].to_i
      if marker < 0
        qids = Question.where(available: true).map(&:id)
      else
        qids = Revision.after(marker).map(&:question_id)
      end
      marker = Revision.all.count > 0 ? Revision.maximum(:id).to_i : 0

      # identify and remove question id already tried
      stabdqids = Stab.where(student_id: student.id).map(&:question_id)
      qids = qids - stabdqids

      # collect the questions
      qsns = Question.where(id: qids)

      # identify and mark questions assigned by teacher as unavailable
      wsqids = Attempt.where(student_id: student.id).map(&:q_selection).map(&:question_id).uniq
      qsns.map{|q| q.available = !(wsqids.include? q.id)}

      # include stabs (already tried questions)
      stabs = Stab.where(student_id: student.id)
      stabs.map{|s| s[:available] = !(wsqids.include? s.question_id)}

      json = {
        :ws => get_questions(qsns) + get_stabs(stabs),
        :marker => marker
      }
    end
    render status: status, json: json
  end

  def refresh_qsns # to be depracated once everyone has vers 4.5
    account = Account.find_by_email(params[:email].downcase)
    if account.nil?
      status = 401
      json = { :message => "Invalid email" }
    elsif account.authentication_token != params[:token]
      status = 404
      json = { :message => "Not Authorized" }
    else
      student = account.loggable
      status = 200
     
      marker = params[:marker].nil? ? 0 : params[:marker].to_i 
      # questions = Question.tagged.where("id > ? and available = true", marker)
      questions = DailyQuiz.load << Puzzle.of_the_day.question
      stabs = Stab.where("student_id = ? and examiner_id IS NOT NULL", student.id)
      json = {
        :ws     => get_questions(questions) + get_stabs(stabs),
        :marker => 0
      }

    end
    render status: status, json: json
  end

  def refresh_ws
    account = Account.find_by_email(params[:email].downcase)
    if account.nil?
      status = 401
      json = { :message => "Invalid email" }
    elsif account.authentication_token != params[:token]
      status = 404
      json = { :message => "Not Authorized" }
    else
      student = Student.find_by_id(account.loggable_id)
      status = 200

      marker = params[:marker].nil? ? 0 : params[:marker].to_i
      ws = Worksheet.where("student_id = ? and id > ?", student.id, marker)
      json = {
        :ws     => get_worksheets(ws),
        :marker => 0
      }
    end
    render status: status, json: json
  end

  def record_action
    # params[:op] = guess, grade, answer, solution, proofread
    if params[:id].nil? 
      # s - student_id, q - question_id, v - qsn version, 
      s = params[:s].to_i
      q = params[:q].to_i
      v = params[:v].to_i

      records = Stab.where(student_id: s, question_id: q, version: v)
      if records.count == 0
        stab = Stab.create(student_id: s, question_id: q, version: v, puzzle: false) 
        records = Stab.where(student_id: s, question_id: q, version: v)
      end
    else
      # id - attempt_id
      ids = params[:id].split(',')

      records = Attempt.where(id: ids)
      s = records[0].student_id
    end

    records.each do |r|
      case params[:op]
        when 'guess'
          g = params[:g].to_i
          r.update_attribute :first_shot, g
        when 'answer'
          r.charge :answer
        when 'solution'
          r.charge :solution
      end
    end

    status = :ok 
    response = {
      stab_id: records[0].id,
      op: params[:op],
      bal: Student.find(s).gredits
    }
    render json: response, status: status
  end

  def validate
    account = Account.find_by_email(params[:email].downcase)
    valid = params[:group_code].nil? || !Sektion.where(uid: "#{params[:group_code]}".upcase).first.nil?
           
    message = "OK"
    if !account.nil?
      message = "EMAIL" 
    elsif !valid
      message = "GROUP_CODE"
    end
    render status: 200, json: message
  end

  def view_hints
    question = Question.find(params[:id])
    hints = question.hints
    ids = hints.map(&:subpart_id).uniq
    json = {}
    ids.each do |j|
       json["#{j}"] = hints.where(subpart_id: j).order(:index).map(&:text)
    end
    render status: 200, json: json 
  end

  def view_fdb
    gr_ids = params[:id].split('-').map{ |id| id.to_i }
    type = params[:type].blank? ? 'GR' : params[:type]
    if type == 'GR'
      grs = Attempt.where(id: gr_ids).map(&:id)
      @comments = Remark.where(attempt_id: grs)
    else
      kaagazs = Kaagaz.where(stab_id: gr_ids).map(&:id)
      @comments = Remark.where(kaagaz_id: kaagazs)
    end
    json = {
      comments: @comments.map{ |c| 
        { 
          id: type == 'GR' ? c.attempt_id : c.kaagaz_id,
          x: c.x, y: c.y, comment: c.tex_comment.text 
        } 
      }
    }
    render status: 200, json: json
  end

  def bill_ws
    ws = Worksheet.find(params[:id])
    ws.bill
    grs = ws.attempts
    qsels = ws.exam.quiz.q_selections.order(:index)
    grIds = qsels.each_with_index.map{ |qsel, i|
      grs.where(q_selection_id: qsel.id).map(&:id).join('-')
    }
    render status:200, json: { gr_ids: grIds }
  end

  def match_name
    account = Account.find_by_email(params[:email].downcase)
    sk = Sektion.where(uid: "#{params[:sektion]}".upcase).first
    candidates = []
    if sk.nil?
      message = "Invalid Group Code"
      render status:500, json: message
    else
      gold = account.loggable
      unmatched = sk.students.where(shell: true)
      candidates = unmatched.select{ |s| Student.min_levenshtein_distance(s, gold) < 6 }
      render status:200, json: candidates
    end
  end

  def claim_account
    account = Account.find_by_email(params[:email].downcase)
    target_id = params[:target_id]
    target = Student.find target_id
    src = account.loggable
    merged = Student.merge target, src
    render json: { success: merged }, status: :ok
  end

  def get_topics
    topics = []
    Topic.all.each do |t|
      # count = Question.where(topic_id: t.id).count
      # next if count == 0 
      topics << {
        id: t.id,
        name: t.name,
        v_id: t.vertical.id,
        v_name: t.vertical.name
      }
    end
    return topics
  end

  private

    def get_questions(questions)
      items = []
      questions.each do |q|
        items << {
          id: "#{q.topic_id}.#{q.id}",
          qid: q.id,
          sid: q.subparts.map(&:id).join(','),
          name: q.created_at.to_s(:db).split(' ').first,
          img: "#{q.uid}/#{rand(4)}",
          imgspan: q.answer_key_span?,
          outof: q.marks,
          examiner: q.examiner_id,
          codex: q.has_codex?,
          ans: q.has_answer?,
          available: q.available
        }
      end
      return items
    end

    def get_stabs(stabs)
      items = []
      stabs.each do |s|
        q = s.question
        items << {
          id: "#{q.topic_id}.#{q.id}",
          qid: q.id,
          sid: s.question.subparts.map(&:id).join(','),
          grId: s.id,
          pzl: s.puzzle,
          name: s.created_at.to_s(:db).split(' ').first,
          img: "#{s.question.uid}/#{s.version}",
          imgspan: s.question.answer_key_span?, 
          scans: s.uploaded? ? s.kaagaz.map(&:path).join(',') : nil,
          outof: q.marks,
          marks: s.quality,
          examiner: s.examiner_id,
          codex: q.has_codex?,
          ans: q.has_answer?,
          available: s.available,
          guesst: s.first_shot,
          bot_ans: s.paid_to_see(:answer),
          bot_soln: s.paid_to_see(:solution)
        } 
      end
      return items
    end

    def get_worksheets(ws)
      worksheets = []
      ws.each do |w|

        next unless (w.billed)
        next unless (w.exam.takehome || !w.received?(:none))

        quiz = w.exam.quiz
        qsels = quiz.q_selections.order(:index)
        qs = qsels.map(&:question)
        atts = w.attempts
        vers = w.signature.split(',')

        items = []
        qsels.each_with_index do |qsel, i|
          qatts = atts.where(q_selection_id: qsel.id).order(:page)
          items << {
            id: "#{w.id}.#{i+1}",
            qid: qs[i].id,
            sid: qs[i].subparts.map(&:id).join(','),
            grId: w.billed ? qatts.map(&:id).join(',') : nil,
            name: "Q.#{i+1}",
            img: "#{qs[i].uid}/#{vers[i]}",
            imgspan: qs[i].answer_key_span?,
            scans: w.billed ? qatts.map(&:scan).join(',') : nil,
            marks: w.billed ? ((qatts[0].feedback > 0 ? 
              qatts.graded().map(&:marks).inject(:+) : -1.0)) : -1.0,
            outof: qs[i].marks,
            examiner: w.billed ? qatts.map(&:examiner_id).first : nil,
            codex: qs[i].has_codex?,
            ans: qs[i].has_answer?,
            guesst: qatts[0].first_shot,
            fdbkMrkr: Remark.where(attempt_id: qatts.map(&:id)).order(:id).map(&:id).max
          }
        end

        remarks = Remark.where(attempt_id: atts.map(&:id))
        worksheets << {
          quizId: w.id,
          quiz: quiz.name,
          price: 20, # Quiz.Price?
          locn: "#{quiz.uid}/#{w.uid}",
          layout: w.exam.takehome ? nil : quiz.page_breaks_after,
          questions: items
	}

      end
      return worksheets
    end

end
