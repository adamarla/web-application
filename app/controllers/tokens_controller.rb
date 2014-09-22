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
      potd = Puzzle.of_the_day.question
      json = { 
        :token => account.authentication_token, 
        :email => account.email,
        :name  => name,
        :id    => account.loggable.id,
        :ws    => worksheets, # to be depracated
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
        :ws    => get_worksheets(ws), # to be deprecated
        :topics=> get_topics(),
        :pzl   => "#{potd.topic_id}.#{potd.id}"
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

  def refresh_stab
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
      stabs = Stab.where("student_id = ? and id > ?", student.id, marker).each
      json = {
        :ws     => get_stabs(stabs),
        :marker => 0
      }
    end
    render status: status, json: json
  end

  def refresh_qsns
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
    if params[:type] == 'GR'
      grs = Attempt.where(id: gr_ids).map(&:id)
      @comments = Remark.where(attempt_id: grs)
    else
      kaagazs = Kaagaz.where(stab_id: gr_ids).map(&:id)
      @comments = Remark.where(kaagaz_id: kaagazs)
    end
    json = {
      comments: @comments.map{ |c| 
        { id: c.attempt_id, x: c.x, y: c.y, comment: c.tex_comment.text } 
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
          examiner: q.examiner_id
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
          scans: s.kaagaz.map(&:path).join(','),
          marks: s.quality,
          outof: q.marks,
          examiner: s.examiner_id
        } 
      end
      return items
    end

    def get_worksheets(ws)
      worksheets = []
      ws.each do |w|

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
            marks: w.billed ? qatts.graded().map(&:marks).inject(:+): -1,
            outof: qs[i].marks,
            examiner: w.billed ? qatts.map(&:examiner_id).first : nil,
            hintMrkr: qs[i].hints.map(&:id).max,
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
