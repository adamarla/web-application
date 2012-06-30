class TrialAccountController < ApplicationController
  respond_to :json

  def create
    p = params[:trial]

    school = School.where(:name => "Gradians TryItOut!").first

    unless school.nil?
      @teacher = Teacher.new :name => p[:name], :school_id => school.id
      username = create_username_for @teacher, :teacher 
      @email = p[:email] 
      @password = p[:zip_code]
      account = @teacher.build_account :email => @email, :username => username,
                :password => @password, :password_confirmation => @password

      maths = Subject.where(:name => "Maths").map(&:id)
      @teacher.set_subjects maths
      @teacher.sektions = school.sektions
	  
      trial = @teacher.build_trial_account :school => p[:school], 
                :zip_code => p[:zip_code], :country => p[:country].to_i
      if @teacher.save
        Mailbot.welcome_email(account).deliver
        render 'trial_account/success'
      end
    else
      render :json => { :status => "Oops!" }, :status => :bad_request
    end # of school.nil?

  end # of method

end
