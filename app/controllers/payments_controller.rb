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

    unless payment.save
      error_text = payment.errors[:base]
    else
      payment.execute 
      unless payment.success?
        error_text = "Uh-oh, problem - #{payment.response_message}"
      end
    end

    unless error_text.nil?
      render :json => {
        :text => error_text, 
        :status => :ok 
      }
    else
      customer = current_account.loggable.customer
      if customer.nil?
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
                error_text = guardian.errors[:base]
                # guardian.errors.each{ |attr,msg| puts "#{attr} - #{msg}" }
              end
            else
              account = student.guardian.account
            end
          end
        when "Guardian"
          guardian = current_account.loggable
          account = guardian.account 
        end            
        customer = account.build_customer currency: p[:currency]
        unless account.save
          error_text = account.errors[:base]
          # account.errors.each{ |attr,msg| puts "#{attr} - #{msg}" }
        end
      end

      if customer.credit_note.nil?
        customer.accounting_docs << AccountingDoc.new_credit_note
      end
      credit_note = customer.credit_note
      customer.apply_payment(payment, credit_note, current_account)
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

end
