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

  def apply_payment(payment, account, accounting_doc = nil)

    if accounting_doc.nil?
      if self.open_credit_note.nil?
        self.accounting_docs << AccountingDoc.new_credit_note 
      end
      accounting_doc = self.open_credit_note

      rc = RateCode.for_course_credit(self.currency) 

      if accounting_doc.balance > 0
        adjustment = accounting_doc.balance
        neg_adj = Transaction.new_adjustment(adjustment*-1, accounting_doc.id, rc.id, account.id)
        accounting_doc.transactions << neg_adj
        accounting_doc.close

        accounting_doc = AccountingDoc.new_credit_note
        self.accounting_docs << accounting_doc
        pos_adj = Transaction.new_adjustment(adjustment, accounting_doc.id, rc.id, account.id)
        accounting_doc.transactions << pos_adj
      end

      pmnt_trans = Transaction.new_payment(payment.credits, payment.id, rc.id, account.id)
      accounting_doc.transactions << pmnt_trans
      self.update_attribute :credit_balance, (self.credit_balance += payment.credits)

    else # is it an invoice? or a one time payment?

    end

  end

  def can_afford?(credits)
    self.credit_balance >= credits
  end

  def purchase_course(course, account)
    code = RateCode.for_course_credit self.currency
    course_purchase = Transaction.new_course course.price, course.id, code.id, account.id
    credit_note = self.open_credit_note
    credit_note.transactions << course_purchase
    self.update_attribute :credit_balance, (self.credit_balance -= course.price)
  end

  def transfer_credits(quantity, recepient, account)
    code = RateCode.for_course_credit self.currency
    from_trans = Transaction.new_transfer(quantity*-1, recepient.id, code.id, account.id)
    credit_note = self.open_credit_note
    credit_note.transactions << from_trans
    self.update_attribute :credit_balance, (self.credit_balance += from_trans.quantity)

    to_trans = Transaction.new_transfer quantity, self.id, code.id, account.id
    if recepient.open_credit_note.nil?
      recepient.accounting_docs << AccountingDoc.new_credit_note
    end
    credit_note = recepient.open_credit_note
    credit_note.transactions << to_trans
    recepient.update_attribute :credit_balance, (recepient.credit_balance += to_trans.quantity)
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