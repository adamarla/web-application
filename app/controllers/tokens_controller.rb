class TokensController < ApplicationController
  respond_to :json

  def create
    @account = Account.where(email: params[:email].downcase).first
    if @account.nil?
      status = 204 # no content, check in other system
      json = { :message => "Check in other system" }
    elsif !@account.valid_password?(params[:password])
      status = 404 
      json = { :message => "Invalid password" }
    else
      @account.ensure_authentication_token!
      status = 200 
      id = @account[:loggable_id]
      gradeables = nil
      case @account.loggable_type
        when "Student"
          name = Student.find_by_id(id).first_name
          worksheets = get_worksheets(@account)
        when "Teacher"
          name = Teacher.find_by_id(id).first_name
        when "Examiner"
          name = Examiner.find_by_id(id).first_name
      end
      json = { 
        :token => @account.authentication_token, 
        :email => @account.email,
        :name  => name,
        :ws    => worksheets
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
    @account = Account.find_by_email(params[:email].downcase)
    if @account.nil?
      status = 401 
      json = { :message => "Invalid email" }
    elsif @account.authentication_token != params[:token]
      status = 404 
      json = { :message => "Not Authorized" }
    else 
      name = Student.find_by_id(@account.loggable_id).first_name
      status = 200
      json = { 
        :token => @account.authentication_token, 
        :email => @account.email,
        :name  => name,
        :ws    => get_worksheets(@account)
      }
    end
    render status: status, json: json
  end

  def view_fdb
    gr_ids = params[:id].split('-').map{ |id| id.to_i }
    grs = Attempt.where(id: gr_ids)
    @comments = Remark.where(attempt_id: grs)
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

  private

    def get_worksheets(account)
      student = Student.find_by_id(account.loggable_id)
      ws = Worksheet.where(student_id: student.id)
      worksheets = []
      ws.each do |w|
        quiz = w.exam.quiz
        qsels = quiz.q_selections.order(:index)
        qs = qsels.map(&:question)
        atts = w.attempts
        vers = w.signature.split(',')

        items = qsels.each_with_index.map{ |qsel, i|
          {
            id: "#{w.id}.#{i+1}",
            grId: w.billed ? atts.where(q_selection_id: qsel.id).map(&:id).join('-') : "",
            name: "Q.#{i+1}",
            img: "#{qs[i].uid}/#{vers[i]}",
            imgspan: qs[i].answer_key_span?,
            scan: w.billed ? atts.where(q_selection_id: qsel.id).first.scan : "",
            scans: w.billed ? atts.where(q_selection_id: qsel.id).map(&:scan).join(',') : nil,
            marks: w.billed ? atts.where(q_selection_id: qsel.id).graded().map(&:marks).inject(:+) : -1.0,
            outof: qs[i].marks
          }
        }

        remarks = Remark.where(attempt_id: atts.map(&:id))
        worksheets << {
          quizId: quiz.id,
          quiz: quiz.name,
          price: 20, # Quiz.Price?
          locn: "#{quiz.uid}/#{w.uid}",
          fdbkMrkr: remarks.count == 0 ? 0 : remarks.order(:id).map(&:id).last,
          layout: w.exam.takehome ? nil : quiz.page_breaks_after,
          questions: items
	}

      end
      return worksheets
    end

end
