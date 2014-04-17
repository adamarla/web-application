#!/bin/env ruby
# encoding: utf-8
#
# http://stackoverflow.com/questions/1739836/invalid-multibyte-char-us-ascii-with-rails-and-ruby-1-9
#
#
# == Schema Information
# Table name: customers
#
#  id             :integer         not null, primary key
#  account_id     :integer
#  credit_balance :integer         default(0)
#  cash_balance   :integer         default(0)
#  currency       :string(3)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

class Customer < ActiveRecord::Base
  belongs_to :account
  
  has_many :accounting_docs
  has_many :transactions, through: :accounting_docs
  has_many :contracts

  def apply_payment(payment, account, accounting_doc = nil)

    if accounting_doc.nil?
      if self.open_credit_note.nil?
        self.accounting_docs << AccountingDoc.new_credit_note 
      end
      accounting_doc = self.open_credit_note
      rc = RateCode.for_course_credit(self.currency) 

      # nullify previous statement by adjusting remaining balance into
      # new statement
      if accounting_doc.balance > 0
        adjustment = accounting_doc.balance
        accounting_doc.transactions.create(account_id: account.id,
            quantity: (adjustment*-1), rate_code_id: rc.id, 
            reference_id: accounting_doc.id, memo: "Negative Adjustment to close statement")
        accounting_doc.close

        accounting_doc = AccountingDoc.new_credit_note
        self.accounting_docs << accounting_doc
        accounting_doc.transactions.create(account_id: account.id,
            quantity: adjustment, rate_code_id: rc.id, 
            reference_id: accounting_doc.id, memo: "Positive Adjustment from prior Statement")
      end

      # apply new payment
      hash = eval payment.response_params
      transaction_id = hash["transaction_id"]
      accounting_doc.transactions.create(account_id: account.id,
          quantity: payment.credits, rate_code_id: rc.id, 
          reference_id: payment.id, memo: "Online Gredit Purchase Paypal ref #{transaction_id}")
      self.update_attribute :credit_balance, (self.credit_balance += payment.credits)
    else # is it an invoice? or a one time payment?

    end

  end

  def can_afford?(credits)
    self.credit_balance >= credits
  end

  def purchase_course(course, account)
    code = RateCode.for_course_credit self.currency
    credit_note = self.open_credit_note
    credit_note.transactions.create(account_id: account.id,
        quantity: (course.price*-1), rate_code_id: code.id,
        reference_id: course.id, memo: "Signed up for #{course.name}")
    self.update_attribute :credit_balance, (self.credit_balance -= course.price)
  end

  def transfer_credits(quantity, recepient, account)
    code = RateCode.for_course_credit self.currency
    credit_note = self.open_credit_note
    credit_note.transactions.create(account_id: account.id, 
        quantity: (quantity*-1), rate_code_id: code.id, 
        reference_id: recepient.id, memo: "Gredits Donated to #{recepient.account.email}")
    self.update_attribute :credit_balance, (self.credit_balance -= quantity)

    if recepient.open_credit_note.nil?
      recepient.accounting_docs << AccountingDoc.new_credit_note
    end
    credit_note = recepient.open_credit_note
    credit_note.transactions.create(account_id: account.id, 
        quantity: quantity, rate_code_id: code.id, 
        reference_id: recepient.id, memo: "Gredits Received from #{account.email}")
    recepient.update_attribute :credit_balance, (recepient.credit_balance += quantity)
  end

  def apply_refund(refund, account)
    code = RateCode.for_course_credit self.currency
    hash = eval refund.response_params
    transaction_id = hash["transaction_id"]
    open_credit_note = self.open_credit_note
    open_credit_note.transactions.create(account_id: account.id,
        quantity: refund.credits, rate_code_id: code.id,
        reference_id: refund.id, memo: "Refund for #{refund.display_value} processed")
    self.update_attribute :credit_balance, 0
    open_credit_note.close
  end

  def generate_invoice(amount, cost_code, quantity, account)
    rate_code = RateCode.where(cost_code_id: cost_code, currency: self.currency, value: amount)
    if rate_code.nil?
      rate_code = RateCode.new cost_code_id: cost_code, 
          currency: self.currency, value: amount
      rate_code.save
    end

    invoice = AccountingDoc.new_invoice
    self.accounting_docs << invoice

    invoice.transactions.create(account_id: account.id,
      quantity: quantity, rate_code_id: rate_code.id,
      reference_id: nil, memo: "Raised Invoice")
    self.update_attribute :cash_balance, -1*amount
    return invoice
  end

  def open_credit_note
    return self.accounting_docs.open_ones.credit_note.first
  end

  def balance
    symbols = {
      "GRD" => "G",
      "INR" => "₹",
      "USD" => "$"
    }
    case self.account.loggable_type
      when "School"
        how_much = self.cash_balance
        currency = self.currency
      else
        how_much = self.credit_balance
        currency = "GRD"
    end
    "#{symbols[currency]}#{how_much}"
  end

  def students
    case self.account.loggable_type
    when "Student"
      Student.where(id: self.account.loggable.id)
    when "Guardian"
      self.account.loggable.students
    end
  end

end
