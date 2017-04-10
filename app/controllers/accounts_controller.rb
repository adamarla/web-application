class AccountsController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!, :except => [ :ask_question, :reset_password, :authenticate_for_quill ]
  respond_to :json

  def authenticate_for_quill 
    a = params[:email].blank? ? nil : Account.where(email: params[:email]).first
    role = a.nil? ? nil : a.role

    if (role == :examiner || role == :admin)
      # valid = params[:password].blank? ? false : a.valid_password?(params[:password])
      valid = true
      if (valid)
        e = a.loggable 
        render json: { allow: true, id: e.id, role: role, name: e.name }, status: :ok 
      else 
        render json: {allow: false }, status: :ok
      end 
    else
      render json: {allow: false}, status: :ok
    end 
  end # of method 

  def update 
    email_updated = passwd_updated = nil
    details = params[:updated]

    unless details[:email].blank?
      email_updated |= (current_account.update_attribute :email, details[:email])
    end

    # Ref: https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-password
    unless details[:password].blank?
      unless details[:password_confirmation].blank?
        passwd_updated |= (current_account.update_attributes(
            password: details[:password], 
            password_confirmation: details[:password_confirmation]))

        sign_in current_account, bypass: true if passwd_updated 
      end
    end

    if email_updated == true
      msg = passwd_updated ? "E-mail and password updated" : "E-mail updated"
    elsif passwd_updated == true
      msg = "Password updated"
    else
      msg = "Nothing updated"
    end
    render json: { notify: {text: msg} }, status: :ok
  end 

  def reset_password
    e = params[:account][:email]
    unless e.blank?
      @a = Account.where(email: e).first
      @pw = @a.nil? ? nil : @a.reset_password
      unless @pw.nil?
        Mailbot.delay.password_reset(@a, @pw) unless @pw.nil?
        render json: { notify: { title: 'Password updated', 
                                 msg: 'Please check your e-mail for the new password.' } }, status: :ok 
      else
        render json: { notify: { title: 'Invalid E-mail?',
                                 msg: 'We do not have this e-mail in our records. Please try again.' } }, status: :ok 
      end
    end # client side validation should preclude the case with blank e-mail.
  end

  def poll_delayed_job_queue
    qids = params[:quizzes].blank? ? [] : params[:quizzes].map(&:to_i)
    eids = params[:exams].blank? ? [] : params[:exams].map(&:to_i)
    wids = params[:worksheets].blank? ? [] : params[:worksheets].map(&:to_i)

    @q = Quiz.where(id: qids).select{ |m| m.compiled? } 
    @e = Exam.where(id: eids, takehome: false).select{ |m| m.compiled? }
    @w = Worksheet.where(id: wids).select{ |m| m.compiled? }
    user = current_account.loggable 
    @indie = user.respond_to?(:indie) ? user.indie : false
  end 

end
