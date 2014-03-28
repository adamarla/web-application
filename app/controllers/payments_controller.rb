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
    p[:cash_value] = p[:cash_value][1..-1] # drop the $ or ₹ prefix

    payment = Payment.new p
    payment.ip_address = request.remote_ip
    payment.expiration = expiration

    err = nil
    unless payment.save
      payment.errors.each{ |attr, msg| err = "#{err} #{attr} - #{msg}" }
    else
      payment.execute
      unless payment.success?
        err = "Uh-oh, problem - #{payment.response_message}"
      end
    end

    unless err.nil?
      render :json => {
        :text => err, 
        :status => :error 
      }
    else
      case current_account.loggable_type
      when "Student"
        student = current_account.loggable
        if student.name == payment.name  
          # student's own credit card  
          account = student.account
        else
          # assume she is using a guardian's credit card
          if student.guardian.nil?
            guardian = student.build_guardian name: p[:name]
            student.save
            # create an account for guardian
            pwd = Guardian.initial_pwd(student.first_name)
            country = Country.where{ name =~ p[:country] }.first
            account = guardian.build_account email: payment.email,
                                             password: pwd,
                                             password_confirmation: pwd,
                                             city: p[:city],
                                             state: p[:state],
                                             zip: p[:zip],
                                             country: country.id
            unless guardian.save
              guardian.errors.each{ |attr, msg| err = "#{err}\n#{attr}-#{msg}" }
            end
          else
            account = student.guardian.account
          end
        end
      when "Guardian"
        guardian = current_account.loggable
        account = guardian.account 
      end            

      if account.customer.nil? 
        customer = account.build_customer currency: p[:currency]
        account.save
      else
        customer = account.customer
      end
      customer.apply_payment(payment, current_account)
      Mailbot.delay.payment_received(customer, payment)
      render :json => {
        :text => "#{customer.balance}", 
        :status => :ok 
      }
    end
  rescue => e
    puts e.message
    puts e.backtrace
    render :json => { 
      :text => "Good golly, a problem! Not to worry, we'll look into it and your card will not be charged!",
      :status => :error 
    }
  end

  def bill_payment

  end

  def refund
    p = params[:payment]
    p[:cash_value] = p[:cash_value][1..-1] # drop the $ or ₹ prefix

    refund = Payment.new p
    refund.ip_address = request.remote_ip

    unless refund.save
      refund.errors.each{ |attr, msg| err = "#{err}\n#{attr}-#{msg}" }
    else
      refund.execute true
      unless refund.success?
        err = "Uh-oh, problem - #{refund.response_message}"
      else
        customer = current_account.loggable.customer
        # customer.apply_refund(refund, current_account)
        # Mailbot.delay.refund_received(customer, refund)
        render :json => {
          :text => "#{customer.balance}", 
          :status => :ok 
        }
      end
    end

    unless err.nil?
      render :json => {
        :text => err, 
        :status => :error
      }
    end

  rescue => e
    puts e.message
    puts e.backtrace
    render :json => { 
      :text => "Good golly, a problem! Not to worry, we'll look into it and your card will not be charged!",
      :status => :error 
    }

  end

end
