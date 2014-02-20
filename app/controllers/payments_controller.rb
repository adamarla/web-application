class PaymentsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def credit_purchase
    p = params[:payment]
    expiration = {
      year: p.delete("expiration(1i)"),
      month: p.delete("expiration(2i)")
    }
    p.delete("expiration(3i)")

    payment = Payment.new p
    payment.ip_address = request.remote_ip
    payment.expiration = expiration

    if payment.save
      response = payment.execute
      if response.success?
        guardian.add_subtract_credit(credits, response.params["transaction_id"])

        customer = current_account.loggable.customer
        if customer.nil?
          if current_account.loggable_type == "Student"
            student = current_account.loggable
            if student.first_name == payment.first_name and 
               student.last_name == payment.last_name
              # student's own credit card  
              account = student.account
            else
              # assume she is using guardian's credit card
              guardian = student.build_guardian first_name: p[:first_name],
                                                last_name: p[:last_name]
              student.save
              # create an account for guardian
              pwd = Guardian.initial_pwd(student.first_name)
              country_id = Country.find_by_name(p[:country]).first
              account = guardian.build_account email: payment.email,
                                               password: pwd,
                                               password_confirmation: pwd,
                                               city: p[:city],
                                               state: p[:state],
                                               zip: p[:zip],
                                               country: country_id
              guardian.save
            end
          else # guardian
            guardian = current_account.loggable
            account = guardian.account 
          end            
          customer = account.build_customer currency: p[:currency]
          account.save
        end
        customer.apply_payment(payment)
        render :json => {
          :text => "#{customer.credit_balance} Gradians Credits", 
          :status => :ok 
        }
      else
        render :json => { 
          :text => "Problem Executing Payment", 
          :status => :error 
        }
      end
    else
      render :json => { 
        :text => payment.errors[:base], 
        :status => :error
      }
    end

  end

  def bill_payment

  end

end
