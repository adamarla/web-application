class TokensController < ApplicationController
  respond_to :json

  def create
    @account = Account.find_by_email(params[:email].downcase)
    if @account.nil?
      status = 401
      json = { :message => "Invalid email" }
    elsif !@account.valid_password?(params[:password])
      status = 404 
      json = { :message => "Invalid password" }
    else
      @account.ensure_authentication_token!
      status = 200 
      id = @account[:loggable_id]
      case @account.loggable_type
        when "Student"
          json = build_json(@account)
        when "Teacher"
          name = Teacher.find_by_id(id)[:first_name]
          json = { 
            :token => @account.authentication_token, 
            :email => @account.email,
            :name  => name
          }
        when "Examiner"
          name = Examiner.find_by_id(id)[:first_name]
          json = { 
            :token => @account.authentication_token, 
            :email => @account.email,
            :name  => name
          }
      end
    end
    render :status => status, :json => json
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
    render :status => status, :json => json
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
      json = build_json(@account)
    end
    render :status => status, :json => json
  end

  private

    def build_json(account)
      student = Student.find_by_id(account.loggable_id)
      without_scans = GradedResponse.of_student(student[:id]).without_scan
      gradeables = without_scans.map do |gr|
        {
          :id     => gr.id,
          :quiz   => gr.testpaper.quiz.name,
          :quizId => gr.testpaper.quiz.id,
          :scan   => get_scan_id(gr),
          :name   => gr.subpart.name_if_in?(gr.testpaper.quiz)
        }
      end 
      return {
        :token => account.authentication_token, 
        :email => account.email,
        :name  => student.first_name,
        :gradeables => gradeables
      }
    end

    def get_scan_id(graded_response)
      ws_id = graded_response[:testpaper_id]
      student_idx = AnswerSheet.where(:testpaper_id => ws_id).map(&:student_id).sort.index(graded_response[:student_id])
#      student_idx = Hash[AnswerSheet.where(:testpaper_id => ws_id).map(&:student_id).sort.map.with_index.to_a][graded_response[:student_id]]
      return encrypt(ws_id, 7) + encrypt(student_idx, 3) + graded_response.page?.to_s(36)
    end

end
