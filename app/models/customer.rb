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

  def apply_payment(payment, accounting_doc, account)
    if accounting_doc.doc_type == AccountingDoc::DOC_TYPE[:credit_note]
      rc = RateCode.for_course_credit(self.currency) 
      amount = payment.credits

      if accounting_doc.balance > 0
        adjustment = accounting_doc.balance
        neg_adj = Transaction.new_adjustment(adjustment * -1, rc, account)
        pos_adj = Transaction.new_adjustment(adjustment, rc, account)
        accounting_doc.transactions << neg_adj
        accounting_doc.close
        accounting_doc = AccountingDoc.new_credit_note
        self.accounting_docs << accounting_doc
        amount = amount + pos_adj.quantity
      end

      pmnt_trans = Transaction.new_payment(payment, rc, account)
      accounting_doc.transactions << pmnt_trans

      unless pos_adj.nil?
        accounting_doc.transactions << pos_adj
        pos_adj.update_attribute :reference_id, neg_adj.id
        neg_adj.update_attribute :reference_id, pos_adj.id
      end

      self.update_attribute :credit_balance, (self.credit_balance += amount)

    else
      # figure out which Contract etc. and apply payment
    end
  end

  def credit_note
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
    "#{how_much} #{symbols[currency]}"
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
