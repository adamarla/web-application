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
    unless params[:id].nil?
      @accounting_docs = Customer.find(params[:id]).accounting_docs.order(:id).reverse_order
    else
      customer = current_account.loggable.customer
      @accounting_docs = customer.accounting_docs.order(:id).reverse_order
    end
  end

  def transactions
    @transactions = AccountingDoc.find(params[:id]).transactions
  end

  def transfer
    transfer = params[:transfer] 
    donor = Customer.find transfer[:donor_id] 
    recepient_acct = Account.find_by_email transfer[:recepient_email]

    if recepient_acct.nil?
      render json: { status: :error, message: "Sorry #{transfer[:recepient_email]} is not registered with us as a Student" }
    elsif recepient_acct.loggable_type != "Student"
      render json: { status: :error, message: "Sorry you can only transfer Gredits to a fellow Student" }
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
      render json: { status: :error, message: "Ya need more Gredits Jim!" }
    else
      customer.purchase_course course, current_account
      render json: { status: :success, message: "Your got it - #{course.name} is yours!" }
    end
  end

  def generate_invoice
    invoice_for = params[:invoice_for]
    amount = invoice_for[:amount]
    currency = invoice_for[:currency]
    cost_code = invoice_for[:cost_code]
    customer_id = invoice_for[:customer_id]
    quantity = invoice_for[:quantity]

    customer = Customer.find(customer_id)
    invoice = customer.generate_invoice(amount, cost_code, quantity, current_account)
    render json: { 
      status: :success, 
      message: "Invoice #{invoice.id} for #{amount} #{currency} #{cost_code} #{school_id}" 
    }
  end

end
