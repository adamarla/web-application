class TrialAccountController < ApplicationController
  respond_to :json

  def create
    p = params[:trial]

    school = School.where(:name => "Gradians TryItOut!").first
    course = Board.where(:name => "Gradians Trial").first.courses.first

    unless school.nil?
      @teacher = school.teachers.build :name => p[:name]
      @email = p[:email] 
      @password = p[:zip_code]

      username = create_username_for @teacher, :teacher 

      # 1. Build the sign-up account 
      account = @teacher.build_account :email => @email, :username => username,
                :password => @password, :password_confirmation => @password
      # 2. Specify the specialization 
      @teacher.specializations.build :subject_id => course.subject_id, :klass => course.klass

      # 3. Store other information provided in the sign-form
      @teacher.build_trial_account :school => p[:school], 
                :zip_code => p[:zip_code], :country => p[:country].to_i

      # If all went well, then send confirmation mail 
      if @teacher.save
        Mailbot.welcome_email(account).deliver
        render 'trial_account/success'
      end
    else
      render :json => { :status => "Oops!" }, :status => :bad_request
    end
  end # of method

end
