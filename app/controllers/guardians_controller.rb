class GuardiansController < ApplicationController
  before_filter :authenticate_account!, :except => [:create]
  respond_to :json

  def create
    data = params[:guardian]

    if data[:guard].blank? # => human entered registration data
      country = data[:country].blank? ? nil : Watan.where{ name =~ "%#{data[:country]}%" }.first

      guardian = Guardian.new name: data[:name]

      location = request.location
      city = state = country = zip = nil

      unless location.nil?
         city = location.city
         state = location.state
         zip = location.postal_code
         country = location.country
         country = Watan.where{ name =~ country }.first
         country = country.id unless country.blank?
      end

      account_details = data[:account]
      account = guardian.build_account email: account_details[:email],
                                      password: account_details[:password],
                                      password_confirmation: account_details[:password],
                                      city: city,
                                      state: state,
                                      postal_code: zip,
                                      country: country

      if guardian.save
        Mailbot.delay.welcome_teacher(guardian.account)
        sign_in guardian.account
        redirect_to guardian_path
      end # no reason for else if client side validations worked
    else # registration data probably entered by a bot
      render :json => { :notify => { :text => "Bot?" } }, :status => :bad_request
    end
  end

  def show
    render :nothing => true, :layout => 'guardians'
  end

  def add_student

  end

  def students
    @students = Guardian.find(params[:id]).students
  end

end
