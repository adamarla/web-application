class CustomersController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def show
    @customer = Customer.find params[:id] 
  end

  def list
    @customers = Customer.all
  end

  def activity
    @accounting_docs = Customer.find(params[:id]).accounting_docs
  end

  def transactions
    @transactions = AccountingDoc.find(params[:id]).transactions
  end

  def transfer
    transfer = params[:transfer] 
    donor = Customer.find transfer[:donor_id] 
    recepient_acct = Account.find_by_email transfer[:recepient_email]

    if recepient_acct.nil?
      render json: { status: error, message: "Sorry #{transfer[:recepient_email]} is not registered with us as a Student" }
    elsif recepient_acct.loggable_type != "Student"
      render json: { status: error, message: "Sorry you can only transfer Gredits to a fellow Student" }
    else
      if recepient_acct.customer.nil?
        recepient_acct.build_customer currency: donor.currency
        recepient_acct.save
      end
      recepient = recepient_acct.customer

      credits = transfer[:credits].to_i
      account = current_account
      if donor.can_afford? credits
        donor.transfer_credits credits, recepient, account
        render json: { status: :success, message: "You're a sweet heart, that's a great gift you just made!" }
      else
        render json: { status: :error, message: "You have only #{donor.credit_balance} Gredits to transfer" }
      end
    end
  end

  def buy_course
    course = Course.find params[:id]
    customer = Customer.find_params[:customer_id]
    account = current_account
    
    unless customer.can_afford? course.price 
      render json: { status: error, message: "Ya need more Gredits Jim!" }
    else
      customer.purchase_course course, current_account
      render json: { status: :success, message: "Your got it - #{course.name} is yours!" }
    end
  end

end
