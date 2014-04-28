class TokensController < ApplicationController
  respond_to :json

  def create
    @account = Account.find_by_email(params[:email].downcase)
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
          name = Student.find_by_id(id)[:first_name]
          gradeables = build_gradeables(@account)
        when "Teacher"
          name = Teacher.find_by_id(id)[:first_name]
        when "Examiner"
          name = Examiner.find_by_id(id)[:first_name]
      end
      json = { 
        :token => @account.authentication_token, 
        :email => @account.email,
        :name  => name,
        :gradeables => gradeables
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
      student = Student.find_by_id(@account.loggable_id) 
      status = 200
      json = { 
        :token => @account.authentication_token, 
        :email => @account.email,
        :name  => student.name,
        :gradeables => build_gradeables(@account)
      }
    end
    render status: status, json: json
  end

  private

    def build_gradeables(account)
      student = Student.find_by_id(account.loggable_id)
      without_scans = GradedResponse.of_student(student[:id]).without_scan.sort
      gradeables = without_scans.map do |g|
        quiz = g.worksheet.exam.quiz
        {
          id: g.id, 
          quiz: quiz.name, 
          quizId: quiz.id, 
          name: g.subpart.name_if_in?(quiz),
          locn: "#{quiz.uid/g.worksheet.uid}"
        }
      end 
      return gradeables
    end

end
